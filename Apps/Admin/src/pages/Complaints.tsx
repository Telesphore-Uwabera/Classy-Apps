import { useState, useEffect } from 'react'
import { Search, MessageSquare, AlertCircle, RefreshCw, Eye, Reply } from 'lucide-react'
import { firebaseService } from '../services/firebaseService'

interface Complaint {
  id: string
  reportedOn: string
  complainee: string
  complaineeId: string
  status: 'pending' | 'replied' | 'resolved'
  subject: string
  message: string
  type: string
  email?: string
  phone?: string
}

export default function Complaints() {
  const [complaints, setComplaints] = useState<Complaint[]>([])
  const [activeTab, setActiveTab] = useState<'pending' | 'replied' | 'resolved'>('pending')
  const [searchTerm, setSearchTerm] = useState('')
  const [loading, setLoading] = useState(true)

  useEffect(() => {
    loadComplaints()
  }, [])

  const loadComplaints = async () => {
    try {
      setLoading(true)
      const complaintsData = await firebaseService.getCollection('complaints')
      
      const complaintsWithDetails = complaintsData.map((complaint: any) => ({
        id: complaint.id,
        reportedOn: complaint.reportedOn?.toDate?.()?.toLocaleDateString() || 
                   complaint.createdAt?.toDate?.()?.toLocaleDateString() || 'Unknown',
        complainee: complaint.complainee || complaint.name || 'Anonymous',
        complaineeId: complaint.complaineeId || complaint.userId || 'Unknown',
        status: complaint.status || 'pending',
        subject: complaint.subject || complaint.title || 'No Subject',
        message: complaint.message || complaint.description || 'No message provided',
        type: complaint.type || complaint.category || 'General',
        email: complaint.email || 'No email',
        phone: complaint.phone || 'No phone'
      }))
      
      setComplaints(complaintsWithDetails)
    } catch (error) {
      console.error('Error loading complaints:', error)
    } finally {
      setLoading(false)
    }
  }

  const updateComplaintStatus = async (complaintId: string, newStatus: 'replied' | 'resolved') => {
    try {
      await firebaseService.updateDocument('complaints', complaintId, { 
        status: newStatus,
        updatedAt: new Date()
      })
      
      setComplaints(prev => 
        prev.map(complaint => 
          complaint.id === complaintId 
            ? { ...complaint, status: newStatus }
            : complaint
        )
      )
    } catch (error) {
      console.error('Error updating complaint status:', error)
    }
  }

  const filteredComplaints = complaints.filter(complaint => {
    const matchesTab = complaint.status === activeTab
    const matchesSearch = complaint.complainee.toLowerCase().includes(searchTerm.toLowerCase()) ||
                         complaint.subject.toLowerCase().includes(searchTerm.toLowerCase()) ||
                         complaint.message.toLowerCase().includes(searchTerm.toLowerCase())
    return matchesTab && matchesSearch
  })

  const getStatusColor = (status: string) => {
    switch (status) {
      case 'pending': return 'bg-yellow-100 text-yellow-800'
      case 'replied': return 'bg-blue-100 text-blue-800'
      case 'resolved': return 'bg-green-100 text-green-800'
      default: return 'bg-gray-100 text-gray-800'
    }
  }

  const getTypeColor = (type: string) => {
    switch (type.toLowerCase()) {
      case 'technical': return 'bg-red-100 text-red-800'
      case 'service': return 'bg-orange-100 text-orange-800'
      case 'billing': return 'bg-purple-100 text-purple-800'
      case 'general': return 'bg-gray-100 text-gray-800'
      default: return 'bg-blue-100 text-blue-800'
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
        <h1 className="text-3xl font-bold text-gray-900">Complaints</h1>
          <p className="text-gray-600 mt-1">Manage customer complaints from Firebase</p>
        </div>
        <button 
          onClick={loadComplaints}
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
            { key: 'pending', label: 'Pending', count: complaints.filter(c => c.status === 'pending').length },
            { key: 'replied', label: 'Replied', count: complaints.filter(c => c.status === 'replied').length },
            { key: 'resolved', label: 'Resolved', count: complaints.filter(c => c.status === 'resolved').length }
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
          placeholder="Search complaints..."
            value={searchTerm}
            onChange={(e) => setSearchTerm(e.target.value)}
          className="w-full pl-10 pr-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-pink-500 focus:border-pink-500"
          />
      </div>

      {/* Complaints List */}
      <div className="space-y-4">
        {filteredComplaints.map((complaint) => (
          <div key={complaint.id} className="bg-white rounded-lg shadow-sm border border-gray-200 p-6 hover:shadow-md transition-shadow">
            <div className="flex justify-between items-start mb-4">
              <div className="flex-1">
                <div className="flex items-center mb-2">
                  <AlertCircle className="w-5 h-5 text-orange-500 mr-2" />
                  <h3 className="text-lg font-semibold text-gray-900">{complaint.subject}</h3>
                </div>
                <div className="flex items-center space-x-4 text-sm text-gray-600">
                  <span>From: {complaint.complainee}</span>
                  <span>•</span>
                  <span>Reported: {complaint.reportedOn}</span>
                  <span>•</span>
                  <span>{complaint.email}</span>
                </div>
              </div>
              <div className="flex items-center space-x-2">
                <span className={`inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium ${getStatusColor(complaint.status)}`}>
                  {complaint.status}
                </span>
                <span className={`inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium ${getTypeColor(complaint.type)}`}>
                  {complaint.type}
                </span>
              </div>
            </div>
            
            <div className="mb-4">
              <p className="text-gray-700">{complaint.message}</p>
            </div>
            
            <div className="flex justify-between items-center">
              <div className="flex items-center text-sm text-gray-500">
                <MessageSquare className="w-4 h-4 mr-1" />
                <span>Complaint ID: {complaint.id}</span>
              </div>
              <div className="flex space-x-2">
                {complaint.status === 'pending' && (
                  <>
                    <button
                      onClick={() => updateComplaintStatus(complaint.id, 'replied')}
                      className="flex items-center px-3 py-1 bg-blue-100 text-blue-800 rounded-lg hover:bg-blue-200 transition-colors text-sm"
                    >
                      <Reply className="w-3 h-3 mr-1" />
                      Reply
                    </button>
                    <button
                      onClick={() => updateComplaintStatus(complaint.id, 'resolved')}
                      className="flex items-center px-3 py-1 bg-green-100 text-green-800 rounded-lg hover:bg-green-200 transition-colors text-sm"
                    >
                      <Eye className="w-3 h-3 mr-1" />
                      Resolve
                    </button>
                  </>
                )}
                {complaint.status === 'replied' && (
                  <button
                    onClick={() => updateComplaintStatus(complaint.id, 'resolved')}
                    className="flex items-center px-3 py-1 bg-green-100 text-green-800 rounded-lg hover:bg-green-200 transition-colors text-sm"
                  >
                    <Eye className="w-3 h-3 mr-1" />
                    Mark Resolved
                      </button>
                )}
                      </div>
                    </div>
        </div>
        ))}
      </div>

      {filteredComplaints.length === 0 && (
        <div className="text-center py-12">
          <AlertCircle className="w-12 h-12 text-gray-400 mx-auto mb-2" />
          <div className="text-gray-500">No {activeTab} complaints found</div>
        </div>
      )}
    </div>
  )
}