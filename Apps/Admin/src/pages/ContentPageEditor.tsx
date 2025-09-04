import { useState } from 'react'
import { ArrowLeft, Save, Eye } from 'lucide-react'
import { useNavigate, useParams } from 'react-router-dom'

export default function ContentPageEditor() {
  const navigate = useNavigate()
  const { id } = useParams()
  
  // Mock content data - in real app, fetch based on id
  const contentData = {
    '1': {
      title: 'About us',
      content: `Henceforth Solutions specializes in innovative, user-centric applications for industries like transportation, food delivery, and logistics. Our suite of apps, including HF Taxi, HF Food Delivery, HF Food Delivery Partner, and HF Food Delivery Driver, reflects our commitment to convenience and connectivity.

Our Mission:
To develop intuitive, reliable, and impactful digital solutions that enhance user experiences and streamline operations across various industries.

Our Vision:
To be a leader in technology innovation, creating seamless digital experiences that connect people, businesses, and services.

Why Choose Us?
• User-Centric Design: We prioritize ease of use and functionality.
• Tailored Solutions: Every app is crafted with the unique needs of its users in mind.
• Commitment to Excellence: We strive for quality in every aspect of our work.
• Seamless Integration: Our platforms connect users, partners, and service providers effortlessly.

Let's build a smarter, more connected future together with Henceforth Solutions.`
    },
    '2': {
      title: 'Privacy Policy',
      content: `Privacy Policy for Classy Apps

Last updated: [Date]

1. Information We Collect
We collect information you provide directly to us, such as when you create an account, use our services, or contact us for support.

2. How We Use Your Information
We use the information we collect to provide, maintain, and improve our services, process transactions, and communicate with you.

3. Information Sharing
We do not sell, trade, or otherwise transfer your personal information to third parties without your consent, except as described in this policy.

4. Data Security
We implement appropriate security measures to protect your personal information against unauthorized access, alteration, disclosure, or destruction.

5. Your Rights
You have the right to access, update, or delete your personal information. You may also opt out of certain communications from us.

6. Changes to This Policy
We may update this privacy policy from time to time. We will notify you of any changes by posting the new policy on this page.

7. Contact Us
If you have any questions about this privacy policy, please contact us at privacy@classy.com.`
    },
    '3': {
      title: 'Terms & Conditions',
      content: `Terms and Conditions for Classy Apps

Last updated: [Date]

1. Acceptance of Terms
By accessing and using our services, you accept and agree to be bound by the terms and provision of this agreement.

2. Use License
Permission is granted to temporarily download one copy of our app for personal, non-commercial transitory viewing only.

3. Disclaimer
The materials on our app are provided on an 'as is' basis. We make no warranties, expressed or implied, and hereby disclaim and negate all other warranties.

4. Limitations
In no event shall Classy or its suppliers be liable for any damages arising out of the use or inability to use the materials on our app.

5. Accuracy of Materials
The materials appearing on our app could include technical, typographical, or photographic errors. We do not warrant that any of the materials are accurate, complete, or current.

6. Links
We have not reviewed all of the sites linked to our app and are not responsible for the contents of any such linked site.

7. Modifications
We may revise these terms of service for our app at any time without notice. By using this app, you are agreeing to be bound by the then current version of these terms.

8. Governing Law
These terms and conditions are governed by and construed in accordance with the laws of Uganda.

9. Contact Information
If you have any questions about these Terms and Conditions, please contact us at legal@classy.com.`
    }
  }

  const currentContent = contentData[id as keyof typeof contentData] || {
    title: 'New Page',
    content: ''
  }

  const [content, setContent] = useState(currentContent.content)
  const [isPreview, setIsPreview] = useState(false)

  const handleSave = () => {
    // Handle save logic
    console.log('Saving content:', content)
    // Navigate back to content pages
    navigate('/content-pages')
  }

  const handlePreview = () => {
    setIsPreview(!isPreview)
  }

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="flex items-center justify-between">
        <div className="flex items-center space-x-4">
          <button
            onClick={() => navigate('/content-pages')}
            className="flex items-center text-gray-600 hover:text-gray-900"
          >
            <ArrowLeft className="w-5 h-5 mr-2" />
            Back
          </button>
          <div>
            <h1 className="text-3xl font-bold text-gray-900">{currentContent.title}</h1>
            <p className="text-gray-600 mt-1">Edit and manage content for this page</p>
          </div>
        </div>
        <div className="flex items-center space-x-3">
          <button
            onClick={handlePreview}
            className="flex items-center px-4 py-2 bg-gray-100 text-gray-700 rounded-lg hover:bg-gray-200 transition-colors"
          >
            <Eye className="w-4 h-4 mr-2" />
            {isPreview ? 'Edit' : 'Preview'}
          </button>
          <button
            onClick={handleSave}
            className="flex items-center px-4 py-2 bg-pink-500 text-white rounded-lg hover:bg-pink-600 transition-colors"
          >
            <Save className="w-4 h-4 mr-2" />
            Save Changes
          </button>
        </div>
      </div>

      {/* Content Editor */}
      <div className="bg-white rounded-lg shadow-sm border border-gray-200">
        {isPreview ? (
          <div className="p-6">
            <div className="prose max-w-none">
              <h2 className="text-2xl font-bold text-gray-900 mb-4">{currentContent.title}</h2>
              <div className="whitespace-pre-wrap text-gray-700 leading-relaxed">
                {content}
              </div>
            </div>
          </div>
        ) : (
          <div className="p-6">
            <div className="space-y-4">
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-2">
                  Page Title
                </label>
                <input
                  type="text"
                  value={currentContent.title}
                  readOnly
                  className="w-full px-3 py-2 border border-gray-300 rounded-lg bg-gray-50 text-gray-500"
                />
              </div>
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-2">
                  Content
                </label>
                <textarea
                  value={content}
                  onChange={(e) => setContent(e.target.value)}
                  rows={20}
                  className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-pink-500 focus:border-pink-500 resize-none"
                  placeholder="Enter your content here..."
                />
              </div>
              <div className="text-sm text-gray-500">
                <p>Tips:</p>
                <ul className="list-disc list-inside mt-1 space-y-1">
                  <li>Use line breaks to separate paragraphs</li>
                  <li>Use bullet points (•) for lists</li>
                  <li>Use bold text (**text**) for emphasis</li>
                  <li>Preview your changes before saving</li>
                </ul>
              </div>
            </div>
          </div>
        )}
      </div>
    </div>
  )
}
