import { useState } from 'react'
import { ArrowLeft, Save } from 'lucide-react'
import { useNavigate, useParams } from 'react-router-dom'

export default function FAQEditor() {
  const navigate = useNavigate()
  const { id } = useParams()
  
  // Mock FAQ data - in real app, fetch based on id
  const faqData = {
    '1': {
      question: 'How do I place an order?',
      answer: 'To place an order, simply browse our menu, select your desired items, add them to your cart, and proceed to checkout. You can pay using various payment methods including cash, card, or digital wallet.',
      type: 'customer'
    },
    '2': {
      question: 'What are your delivery hours?',
      answer: 'We deliver from 8:00 AM to 10:00 PM, seven days a week. Delivery times may vary depending on your location and current order volume.',
      type: 'customer'
    },
    '3': {
      question: 'How do I become a driver?',
      answer: 'To become a driver, download our driver app, complete the registration process, upload required documents (license, insurance, vehicle registration), and wait for approval from our team.',
      type: 'driver'
    }
  }

  const currentFAQ = faqData[id as keyof typeof faqData] || {
    question: '',
    answer: '',
    type: 'customer'
  }

  const [question, setQuestion] = useState(currentFAQ.question)
  const [answer, setAnswer] = useState(currentFAQ.answer)
  const [type, setType] = useState(currentFAQ.type)

  const handleSave = () => {
    // Handle save logic
    console.log('Saving FAQ:', { question, answer, type })
    // Navigate back to FAQs
    navigate('/faqs')
  }

  const isNewFAQ = !id || id === 'new'

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="flex items-center justify-between">
        <div className="flex items-center space-x-4">
          <button
            onClick={() => navigate('/faqs')}
            className="flex items-center text-gray-600 hover:text-gray-900"
          >
            <ArrowLeft className="w-5 h-5 mr-2" />
            Back
          </button>
          <div>
            <h1 className="text-3xl font-bold text-gray-900">
              {isNewFAQ ? 'Add New FAQ' : 'Edit FAQ'}
            </h1>
            <p className="text-gray-600 mt-1">
              {isNewFAQ ? 'Create a new frequently asked question' : 'Update FAQ information'}
            </p>
          </div>
        </div>
        <button
          onClick={handleSave}
          className="flex items-center px-4 py-2 bg-pink-500 text-white rounded-lg hover:bg-pink-600 transition-colors"
        >
          <Save className="w-4 h-4 mr-2" />
          {isNewFAQ ? 'Create FAQ' : 'Save Changes'}
        </button>
      </div>

      {/* FAQ Form */}
      <div className="bg-white rounded-lg shadow-sm border border-gray-200 p-6">
        <div className="grid grid-cols-1 lg:grid-cols-2 gap-8">
          {/* Left Column - Form Fields */}
          <div className="space-y-6">
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">
                FAQ Type *
              </label>
              <select
                value={type}
                onChange={(e) => setType(e.target.value)}
                className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-pink-500 focus:border-pink-500"
                required
              >
                <option value="customer">Customer</option>
                <option value="driver">Driver</option>
                <option value="vendor">Vendor</option>
              </select>
            </div>

            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">
                Question *
              </label>
              <input
                type="text"
                value={question}
                onChange={(e) => setQuestion(e.target.value)}
                className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-pink-500 focus:border-pink-500"
                placeholder="Enter the question"
                required
              />
            </div>

            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">
                Answer *
              </label>
              <textarea
                value={answer}
                onChange={(e) => setAnswer(e.target.value)}
                rows={8}
                className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-pink-500 focus:border-pink-500 resize-none"
                placeholder="Enter the detailed answer"
                required
              />
            </div>
          </div>

          {/* Right Column - Preview */}
          <div className="space-y-6">
            <div>
              <h3 className="text-lg font-semibold text-gray-900 mb-4">Preview</h3>
              <div className="bg-white rounded-lg shadow-sm border border-gray-200 p-4">
                <div className="flex items-center justify-between">
                  <div className="flex items-center flex-1">
                    <div className="mr-3 p-1">
                      <div className="w-4 h-4 text-gray-600">▼</div>
                    </div>
                    <h3 className="text-lg font-medium text-gray-900 flex-1">
                      {question || 'Your question will appear here'}
                    </h3>
                  </div>
                </div>
                <div className="mt-4 pl-7">
                  <p className="text-gray-700 leading-relaxed">
                    {answer || 'Your answer will appear here'}
                  </p>
                </div>
              </div>
            </div>

            {/* FAQ Information */}
            <div>
              <h3 className="text-lg font-semibold text-gray-900 mb-4">FAQ Information</h3>
              <div className="space-y-3">
                <div className="flex justify-between">
                  <span className="text-sm text-gray-600">FAQ ID:</span>
                  <span className="text-sm text-gray-900">{id || 'Auto-generated'}</span>
                </div>
                <div className="flex justify-between">
                  <span className="text-sm text-gray-600">Type:</span>
                  <span className="text-sm text-gray-900 capitalize">{type}</span>
                </div>
                <div className="flex justify-between">
                  <span className="text-sm text-gray-600">Status:</span>
                  <span className="text-sm text-green-600">Active</span>
                </div>
                <div className="flex justify-between">
                  <span className="text-sm text-gray-600">Created:</span>
                  <span className="text-sm text-gray-900">
                    {isNewFAQ ? 'Will be set on creation' : '15 May 2025'}
                  </span>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>

      {/* Tips */}
      <div className="bg-blue-50 border border-blue-200 rounded-lg p-4">
        <h4 className="text-sm font-medium text-blue-900 mb-2">Tips for creating FAQs:</h4>
        <ul className="text-sm text-blue-800 space-y-1">
          <li>• Keep questions clear and concise</li>
          <li>• Provide detailed, helpful answers</li>
          <li>• Use the appropriate type (Customer/Driver/Vendor)</li>
          <li>• Consider common user concerns and pain points</li>
        </ul>
      </div>
    </div>
  )
}
