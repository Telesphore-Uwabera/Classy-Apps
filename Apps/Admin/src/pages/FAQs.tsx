import { useState } from 'react'
import { Search, Plus, Edit, Trash2, HelpCircle, ChevronDown, ChevronRight } from 'lucide-react'
import { useNavigate } from 'react-router-dom'

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
      question: 'What are your restaurant\'s hours of operation?',
      answer: 'Our restaurant partners have varying hours. You can check the specific hours for each restaurant in the app when placing your order.',
      type: 'customer',
      createdAt: '15 May 2025'
    },
    {
      id: '7',
      question: 'Do you offer online reservations?',
      answer: 'Currently, we focus on delivery and takeout orders. For dine-in reservations, please contact the restaurant directly.',
      type: 'customer',
      createdAt: '15 May 2025'
    },
    {
      id: '8',
      question: 'Are there vegetarian and vegan options available?',
      answer: 'Yes, we have many vegetarian and vegan options available. You can filter restaurants and dishes by dietary preferences in the app.',
      type: 'customer',
      createdAt: '15 May 2025'
    }
  ])

  const [activeTab, setActiveTab] = useState<'customer' | 'driver' | 'vendor'>('customer')
  const [searchTerm, setSearchTerm] = useState('')

  const filteredFaqs = faqs.filter(faq => {
    const matchesTab = faq.type === activeTab
    const matchesSearch = faq.question.toLowerCase().includes(searchTerm.toLowerCase()) ||
                         faq.answer.toLowerCase().includes(searchTerm.toLowerCase())
    return matchesTab && matchesSearch
  })

  const toggleExpanded = (faqId: string) => {
    setFaqs(prev => prev.map(faq => 
      faq.id === faqId 
        ? { ...faq, isExpanded: !faq.isExpanded }
        : faq
    ))
  }

  const handleAddFAQ = () => {
    navigate('/faqs/new')
  }

  const handleEditFAQ = (faqId: string) => {
    navigate(`/faqs/${faqId}/edit`)
  }

  const handleDeleteFAQ = (faqId: string) => {
    if (window.confirm('Are you sure you want to delete this FAQ?')) {
      setFaqs(prevFaqs => prevFaqs.filter(faq => faq.id !== faqId))
    }
  }

  return (
    <div className="space-y-6">
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-3xl font-bold text-gray-900">FAQs</h1>
          <p className="text-gray-600 mt-1">Manage frequently asked questions</p>
        </div>
        <button
          onClick={handleAddFAQ}
          className="flex items-center px-4 py-2 bg-pink-500 text-white rounded-lg hover:bg-pink-600 transition-colors"
        >
          <Plus className="w-4 h-4 mr-2" />
          + Add
        </button>
      </div>

      {/* Search */}
      <div className="flex items-center space-x-4">
        <div className="flex-1 relative">
          <Search className="absolute left-3 top-1/2 transform -translate-y-1/2 text-gray-400 w-4 h-4" />
          <input
            type="text"
            placeholder="Search FAQs..."
            value={searchTerm}
            onChange={(e) => setSearchTerm(e.target.value)}
            className="w-full pl-10 pr-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-yellow-500 focus:border-yellow-500"
          />
        </div>
      </div>

      {/* Tabs */}
      <div className="border-b border-gray-200">
        <nav className="-mb-px flex space-x-8">
          {[
            { key: 'customer', label: 'Customer' },
            { key: 'driver', label: 'Driver' },
            { key: 'vendor', label: 'Restaurant' }
          ].map((tab) => (
            <button
              key={tab.key}
              onClick={() => setActiveTab(tab.key as any)}
              className={`py-2 px-1 border-b-2 font-medium text-sm ${
                activeTab === tab.key
                  ? 'border-yellow-500 text-yellow-600'
                  : 'border-transparent text-gray-500 hover:text-gray-700 hover:border-gray-300'
              }`}
            >
              {tab.label}
            </button>
          ))}
        </nav>
      </div>

      {/* FAQs List */}
      <div className="space-y-4">
        {filteredFaqs.length > 0 ? (
          filteredFaqs.map((faq) => (
            <div key={faq.id} className="bg-white rounded-lg shadow-sm border border-gray-200 p-4">
              <div className="flex items-center justify-between">
                <div className="flex items-center flex-1">
                  <button
                    onClick={() => toggleExpanded(faq.id)}
                    className="mr-3 p-1 hover:bg-gray-100 rounded"
                  >
                    {faq.isExpanded ? (
                      <ChevronDown className="w-4 h-4 text-gray-600" />
                    ) : (
                      <ChevronRight className="w-4 h-4 text-gray-600" />
                    )}
                  </button>
                  <h3 className="text-lg font-medium text-gray-900 flex-1">{faq.question}</h3>
                </div>
                <div className="flex items-center space-x-2">
                  <button
                    onClick={() => handleEditFAQ(faq.id)}
                    className="w-8 h-8 bg-yellow-100 text-yellow-600 rounded-full flex items-center justify-center hover:bg-yellow-200 transition-colors"
                  >
                    <Edit className="w-4 h-4" />
                  </button>
                  <button
                    onClick={() => handleDeleteFAQ(faq.id)}
                    className="w-8 h-8 bg-red-100 text-red-600 rounded-full flex items-center justify-center hover:bg-red-200 transition-colors"
                  >
                    <Trash2 className="w-4 h-4" />
                  </button>
                </div>
              </div>
              {faq.isExpanded && (
                <div className="mt-4 pl-7">
                  <p className="text-gray-700 leading-relaxed">{faq.answer}</p>
                </div>
              )}
            </div>
          ))
        ) : (
          <div className="bg-white rounded-lg shadow-sm border border-gray-200 p-12 text-center">
            <div className="w-16 h-16 bg-gray-100 rounded-lg flex items-center justify-center mx-auto mb-4">
              <HelpCircle className="w-8 h-8 text-gray-400" />
            </div>
            <p className="text-gray-500 text-lg">No result found</p>
            <p className="text-gray-400 text-sm">No FAQs found for the selected category</p>
          </div>
        )}
      </div>
    </div>
  )
}
