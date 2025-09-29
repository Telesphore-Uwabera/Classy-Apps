import { useState, useEffect } from 'react'
import { Search, MessageSquare, Mail, Phone, RefreshCw, Reply, Eye } from 'lucide-react'
import { firebaseService } from '../services/firebaseService'

interface ContactInquiry {
  id: string
  name: string
  email: string
  message: string
  status: 'pending' | 'replied'
  createdAt: string
  phone?: string
  subject?: string
}

export default function ContactUs() {
  const [inquiries, setInquiries] = useState<ContactInquiry[]>([])
  const [activeTab, setActiveTab] = useState<'pending' | 'replied'>('pending')
  const [searchTerm, setSearchTerm] = useState('')
  const [loading, setLoading] = useState(true)

  useEffect(() => {
    loadInquiries()
  }, [])

  const loadInquiries = async () => {
    try {
      setLoading(true)
      const inquiriesData = await firebaseService.getCollection('contact_inquiries')
      
      const inquiriesWithDetails = inquiriesData.map((inquiry: any) => ({
        id: inquiry.id,
        name: inquiry.name || 'Anonymous',
        email: inquiry.email || 'No email',
        message: inquiry.message || inquiry.description || 'No message provided',
        status: inquiry.status || 'pending',
        createdAt: inquiry.createdAt?.toDate?.()?.toLocaleDateString() || 'Unknown',
        phone: inquiry.phone || 'No phone',
        subject: inquiry.subject || inquiry.title || 'General Inquiry'
      }))
      
      setInquiries(inquiriesWithDetails)
    } catch (error) {
      console.error('Error loading contact inquiries:', error)
    } finally {
      setLoading(false)
    }
  }

  const updateInquiryStatus = async (inquiryId: string, newStatus: 'replied') => {
    try {
      await firebaseService.updateDocument('contact_inquiries', inquiryId, { 
        status: newStatus,
        repliedAt: new Date()
      })
      
      setInquiries(prev => 
        prev.map(inquiry => 
          inquiry.id === inquiryId 
            ? { ...inquiry, status: newStatus }
            : inquiry
        )
      )
    } catch (error) {
      console.error('Error updating inquiry status:', error)
    }
  }

  const filteredInquiries = inquiries.filter(inquiry => {
    const matchesTab = inquiry.status === activeTab
    const matchesSearch = inquiry.name.toLowerCase().includes(searchTerm.toLowerCase()) ||
                         inquiry.email.toLowerCase().includes(searchTerm.toLowerCase()) ||
                         inquiry.message.toLowerCase().includes(searchTerm.toLowerCase()) ||
                         inquiry.subject?.toLowerCase().includes(searchTerm.toLowerCase())
    return matchesTab && matchesSearch
  })

  const getStatusColor = (status: string) => {
    switch (status) {
      case 'pending': return 'bg-yellow-100 text-yellow-800'
      case 'replied': return 'bg-green-100 text-green-800'
      default: return 'bg-gray-100 text-gray-800'
    }
  }

  if (loading) {
    return (
      <div className="space-y-6">
        <div className="flex justify-center items-center h-64">
          <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-pink-500"></div>
        </div>
      </div>
    )
  }

  return (
    <div className="space-y-6">
      <div className="flex justify-between items-center">
      <div>
        <h1 className="text-3xl font-bold text-gray-900">Contact Us</h1>
          <p className="text-gray-600 mt-1">Manage customer inquiries from Firebase</p>
        </div>
        <button 
          onClick={loadInquiries}
          className="flex items-center px-4 py-2 bg-pink-500 text-white rounded-lg hover:bg-pink-600 transition-colors"
        >
          <RefreshCw className="w-4 h-4 mr-2" />
          Refresh
        </button>
      </div>

      {/* Tabs */}
      <div className="border-b border-gray-200">
        <nav className="-mb-px flex space-x-8">
          {[
            { key: 'pending', label: 'Pending', count: inquiries.filter(i => i.status === 'pending').length },
            { key: 'replied', label: 'Replied', count: inquiries.filter(i => i.status === 'replied').length }
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
          placeholder="Search inquiries..."
            value={searchTerm}
            onChange={(e) => setSearchTerm(e.target.value)}
          className="w-full pl-10 pr-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-pink-500 focus:border-pink-500"
          />
      </div>

      {/* Inquiries List */}
      <div className="space-y-4">
        {filteredInquiries.map((inquiry) => (
          <div key={inquiry.id} className="bg-white rounded-lg shadow-sm border border-gray-200 p-6 hover:shadow-md transition-shadow">
            <div className="flex justify-between items-start mb-4">
              <div className="flex-1">
                <div className="flex items-center mb-2">
                  <MessageSquare className="w-5 h-5 text-blue-500 mr-2" />
                  <h3 className="text-lg font-semibold text-gray-900">{inquiry.subject}</h3>
                </div>
                <div className="flex items-center space-x-4 text-sm text-gray-600 mb-2">
                  <div className="flex items-center">
                    <Mail className="w-4 h-4 mr-1" />
                    <span>{inquiry.email}</span>
                  </div>
                  {inquiry.phone && inquiry.phone !== 'No phone' && (
                    <div className="flex items-center">
                      <Phone className="w-4 h-4 mr-1" />
                      <span>{inquiry.phone}</span>
                    </div>
                  )}
                  <span>•</span>
                  <span>Received: {inquiry.createdAt}</span>
                </div>
                <div className="text-sm font-medium text-gray-900">
                  From: {inquiry.name}
                </div>
              </div>
              <span className={`inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium ${getStatusColor(inquiry.status)}`}>
                {inquiry.status}
                    </span>
            </div>
            
            <div className="mb-4">
              <p className="text-gray-700">{inquiry.message}</p>
            </div>
            
            <div className="flex justify-between items-center">
              <div className="text-sm text-gray-500">
                Inquiry ID: {inquiry.id}
              </div>
              <div className="flex space-x-2">
                {inquiry.status === 'pending' && (
                    <button
                    onClick={() => updateInquiryStatus(inquiry.id, 'replied')}
                    className="flex items-center px-3 py-1 bg-blue-100 text-blue-800 rounded-lg hover:bg-blue-200 transition-colors text-sm"
                  >
                    <Reply className="w-3 h-3 mr-1" />
                    Mark as Replied
                  </button>
                )}
                <button className="flex items-center px-3 py-1 bg-gray-100 text-gray-800 rounded-lg hover:bg-gray-200 transition-colors text-sm">
                  <Eye className="w-3 h-3 mr-1" />
                  View Details
                    </button>
              </div>
            </div>
          </div>
        ))}
      </div>

      {filteredInquiries.length === 0 && (
        <div className="text-center py-12">
          <MessageSquare className="w-12 h-12 text-gray-400 mx-auto mb-2" />
          <div className="text-gray-500">No {activeTab} inquiries found</div>
        </div>
      )}
    </div>
  )
}