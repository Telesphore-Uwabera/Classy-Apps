import { useState, useEffect } from 'react'
import { Search, Plus, Edit, Trash2, HelpCircle, ChevronDown, ChevronRight, RefreshCw } from 'lucide-react'
import { useNavigate } from 'react-router-dom'
import { firebaseService } from '../services/firebaseService'

interface FAQ {
  id: string
  question: string
  answer: string
  type: 'customer' | 'driver' | 'vendor'
  createdAt: string
  isExpanded?: boolean
}

export default function FAQs() {
  const navigate = useNavigate()
  const [faqs, setFaqs] = useState<FAQ[]>([
    {
      id: '1',
      question: 'How are drivers paid?',
      answer: 'Drivers are paid weekly through our secure payment system. Payments are processed every Friday and deposited directly to your registered bank account.',
      type: 'driver',
      createdAt: '15 May 2025'
    },
    {
      id: '2',
      question: 'How do I receive delivery orders?',
      answer: 'You will receive delivery orders through the driver app. Make sure to keep your app notifications enabled and your status set to "Available".',
      type: 'driver',
      createdAt: '15 May 2025'
    },
    {
      id: '3',
      question: 'What are the requirements to become a driver?',
      answer: 'To become a driver, you need a valid driver\'s license, vehicle registration, insurance, and a clean driving record. You must also be at least 21 years old.',
      type: 'driver',
      createdAt: '15 May 2025'
    },
    {
      id: '4',
      question: 'How do I sign up as a delivery driver?',
      answer: 'Download the ReadyEats Driver app, complete the registration process, upload required documents, and wait for approval from our team.',
      type: 'driver',
      createdAt: '15 May 2025'
    },
    {
      id: '5',
      question: 'Do you serve alcohol?',
      answer: 'Yes, we serve alcohol at participating restaurants. Please note that you must be 21 or older to order alcoholic beverages.',
      type: 'customer',
      createdAt: '15 May 2025'
    },
    {
      id: '6',
      question: 'How do I track my order?',
      answer: 'You can track your order in real-time through the customer app. You\'ll receive notifications when your order is confirmed, being prepared, and out for delivery.',
      type: 'customer',
      createdAt: '15 May 2025'
    },
    {
      id: '7',
      question: 'What payment methods do you accept?',
      answer: 'We accept all major credit cards, debit cards, PayPal, Apple Pay, Google Pay, and cash on delivery in select areas.',
      type: 'customer',
      createdAt: '15 May 2025'
    },
    {
      id: '8',
      question: 'How do I become a restaurant partner?',
      answer: 'To become a restaurant partner, complete our online application, provide business documentation, and schedule a meeting with our partnership team.',
      type: 'vendor',
      createdAt: '15 May 2025'
    },
    {
      id: '9',
      question: 'What are the commission rates for restaurants?',
      answer: 'Commission rates vary by location and partnership level. Contact our partnership team for specific rates and promotional opportunities.',
      type: 'vendor',
      createdAt: '15 May 2025'
    },
    {
      id: '10',
      question: 'How do I update my restaurant menu?',
      answer: 'You can update your menu anytime through the vendor app. Changes are reviewed and go live within 24 hours.',
      type: 'vendor',
      createdAt: '15 May 2025'
    }
  ])
  const [loading, setLoading] = useState(false)
  const [searchTerm, setSearchTerm] = useState('')
  const [activeTab, setActiveTab] = useState<'customer' | 'driver' | 'vendor'>('customer')

  const loadFAQsFromFirebase = async () => {
    try {
      setLoading(true)
      const faqsData = await firebaseService.getCollection('faqs')
      
      if (faqsData && faqsData.length > 0) {
        const faqsWithDetails = faqsData.map((faq: any) => ({
          id: faq.id,
          question: faq.question || 'No question',
          answer: faq.answer || 'No answer provided',
          type: faq.type || 'customer',
          createdAt: faq.createdAt?.toDate?.()?.toLocaleDateString() || 'Unknown',
          isExpanded: false
        }))
        
        setFaqs(faqsWithDetails)
      }
    } catch (error) {
      console.error('Error loading FAQs from Firebase:', error)
      // Keep the default mock data if Firebase fails
    } finally {
      setLoading(false)
    }
  }

  const deleteFAQ = async (faqId: string) => {
    if (window.confirm('Are you sure you want to delete this FAQ?')) {
      try {
        // Try to delete from Firebase first
        await firebaseService.deleteDocument('faqs', faqId)
        setFaqs(prev => prev.filter(faq => faq.id !== faqId))
      } catch (error) {
        console.error('Error deleting FAQ from Firebase:', error)
        // If Firebase fails, just remove from local state
        setFaqs(prev => prev.filter(faq => faq.id !== faqId))
      }
    }
  }

  const toggleExpanded = (faqId: string) => {
    setFaqs(prev => 
      prev.map(faq => 
        faq.id === faqId 
          ? { ...faq, isExpanded: !faq.isExpanded }
          : faq
      )
    )
  }

  const filteredFAQs = faqs.filter(faq => {
    const matchesTab = faq.type === activeTab
    const matchesSearch = faq.question.toLowerCase().includes(searchTerm.toLowerCase()) ||
                         faq.answer.toLowerCase().includes(searchTerm.toLowerCase())
    return matchesTab && matchesSearch
  })

  const getTypeColor = (type: string) => {
    switch (type) {
      case 'customer': return 'bg-blue-100 text-blue-800'
      case 'driver': return 'bg-green-100 text-green-800'
      case 'vendor': return 'bg-purple-100 text-purple-800'
      default: return 'bg-gray-100 text-gray-800'
    }
  }

  return (
    <div className="space-y-6">
      <div className="flex justify-between items-center">
        <div>
          <h1 className="text-3xl font-bold text-gray-900">FAQs</h1>
          <p className="text-gray-600 mt-1">Manage frequently asked questions</p>
        </div>
        <div className="flex space-x-2">
          <button 
            onClick={loadFAQsFromFirebase}
            disabled={loading}
            className="flex items-center px-4 py-2 bg-gray-500 text-white rounded-lg hover:bg-gray-600 transition-colors disabled:opacity-50"
          >
            <RefreshCw className={`w-4 h-4 mr-2 ${loading ? 'animate-spin' : ''}`} />
            Load from Firebase
          </button>
          <button 
            onClick={() => navigate('/faqs/add')}
            className="flex items-center px-4 py-2 bg-pink-500 text-white rounded-lg hover:bg-pink-600 transition-colors"
          >
            <Plus className="w-4 h-4 mr-2" />
            Add FAQ
          </button>
        </div>
      </div>

      {/* Tabs */}
      <div className="border-b border-gray-200">
        <nav className="-mb-px flex space-x-8">
          {[
            { key: 'customer', label: 'Customer FAQs', count: faqs.filter(f => f.type === 'customer').length },
            { key: 'driver', label: 'Driver FAQs', count: faqs.filter(f => f.type === 'driver').length },
            { key: 'vendor', label: 'Vendor FAQs', count: faqs.filter(f => f.type === 'vendor').length }
          ].map((tab) => (
            <button
              key={tab.key}
              onClick={() => setActiveTab(tab.key as any)}
              className={`py-2 px-1 border-b-2 font-medium text-sm flex items-center ${
                activeTab === tab.key
                  ? 'border-yellow-500 text-yellow-600'
                  : 'border-transparent text-gray-500 hover:text-gray-700 hover:border-gray-300'
              }`}
            >
              {tab.label}
              <span className={`ml-2 py-0.5 px-2 rounded-full text-xs ${
                activeTab === tab.key ? 'bg-yellow-100 text-yellow-800' : 'bg-gray-100 text-gray-600'
              }`}>
                {tab.count}
              </span>
            </button>
          ))}
        </nav>
      </div>

      {/* Search */}
      <div className="relative">
        <Search className="absolute left-3 top-1/2 transform -translate-y-1/2 text-gray-400 w-4 h-4" />
        <input
          type="text"
          placeholder="Search FAQs..."
          value={searchTerm}
          onChange={(e) => setSearchTerm(e.target.value)}
          className="w-full pl-10 pr-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-pink-500 focus:border-pink-500"
        />
      </div>

      {/* FAQs List */}
      <div className="space-y-4">
        {filteredFAQs.map((faq) => (
          <div key={faq.id} className="bg-white rounded-lg shadow-sm border border-gray-200 overflow-hidden">
            <div 
              className="p-6 cursor-pointer hover:bg-gray-50 transition-colors"
              onClick={() => toggleExpanded(faq.id)}
            >
              <div className="flex justify-between items-start">
                <div className="flex-1">
                  <div className="flex items-center mb-2">
                    <HelpCircle className="w-5 h-5 text-yellow-500 mr-2" />
                    <h3 className="text-lg font-semibold text-gray-900">{faq.question}</h3>
                  </div>
                  <div className="flex items-center space-x-4 text-sm text-gray-600">
                    <span>Created: {faq.createdAt}</span>
                    <span className={`inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium ${getTypeColor(faq.type)}`}>
                      {faq.type}
                    </span>
                  </div>
                </div>
                <div className="flex items-center space-x-2 ml-4">
                  <button 
                    onClick={(e) => {
                      e.stopPropagation()
                      navigate(`/faqs/${faq.id}/edit`)
                    }}
                    className="text-gray-400 hover:text-blue-600 transition-colors"
                  >
                    <Edit className="w-4 h-4" />
                  </button>
                  <button 
                    onClick={(e) => {
                      e.stopPropagation()
                      deleteFAQ(faq.id)
                    }}
                    className="text-gray-400 hover:text-red-600 transition-colors"
                  >
                    <Trash2 className="w-4 h-4" />
                  </button>
                  {faq.isExpanded ? (
                    <ChevronDown className="w-5 h-5 text-gray-400" />
                  ) : (
                    <ChevronRight className="w-5 h-5 text-gray-400" />
                  )}
                </div>
              </div>
            </div>
            
            {faq.isExpanded && (
              <div className="px-6 pb-6 border-t border-gray-200 bg-gray-50">
                <div className="pt-4">
                  <p className="text-gray-700 leading-relaxed">{faq.answer}</p>
                </div>
              </div>
            )}
          </div>
        ))}
      </div>

      {filteredFAQs.length === 0 && (
        <div className="text-center py-12">
          <HelpCircle className="w-12 h-12 text-gray-400 mx-auto mb-2" />
          <div className="text-gray-500">No FAQs found for {activeTab}s</div>
        </div>
      )}
    </div>
  )
}