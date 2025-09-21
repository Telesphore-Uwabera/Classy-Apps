import { useState, useEffect } from 'react'
import { ArrowLeft, Edit, FileText, Calendar, User } from 'lucide-react'
import { useNavigate, useParams } from 'react-router-dom'
import { firebaseService } from '../services/firebaseService'

interface ContentPageData {
  id: string
  title: string
  content: string
  type: 'customer' | 'driver' | 'vendor'
  createdAt: string
  updatedAt: string
  slug: string
  isActive: boolean
  author?: string
}

export default function ContentPageViewer() {
  const navigate = useNavigate()
  const { id } = useParams()
  const [contentPage, setContentPage] = useState<ContentPageData | null>(null)
  const [loading, setLoading] = useState(true)

  useEffect(() => {
    if (id) {
      loadContentPage()
    }
  }, [id])

  const loadContentPage = async () => {
    try {
      setLoading(true)
      
      // First try to load from Firebase
      if (id) {
        try {
          const pageData = await firebaseService.getDocument('content_pages', id)
          if (pageData) {
            setContentPage({
              id: pageData.id,
              title: pageData.title || 'Untitled Page',
              content: pageData.content || 'No content available.',
              type: pageData.type || 'customer',
              createdAt: pageData.createdAt?.toDate?.()?.toLocaleDateString() || 'Unknown',
              updatedAt: pageData.updatedAt?.toDate?.()?.toLocaleDateString() || 'Unknown',
              slug: pageData.slug || '',
              isActive: pageData.isActive !== false,
              author: pageData.author || 'Admin'
            })
            return
          }
        } catch (error) {
          console.error('Error loading from Firebase:', error)
        }
      }

      // Fallback to sample content based on ID
      const samplePages: { [key: string]: ContentPageData } = {
        '1': {
          id: '1',
          title: 'About us',
          content: `# About Classy App

Welcome to Classy App, your premier food delivery platform that connects customers with the best restaurants and delivery drivers in your area.

## Our Mission

We are committed to providing a seamless, fast, and reliable food delivery experience that brings your favorite meals right to your doorstep. Our platform serves customers, restaurants, and delivery drivers with equal dedication.

## What We Offer

- **For Customers**: Browse hundreds of restaurants, place orders, and track deliveries in real-time
- **For Restaurants**: Expand your reach and grow your business with our delivery network
- **For Drivers**: Earn money on your schedule with flexible delivery opportunities

## Our Values

- **Quality**: We partner with the best restaurants to ensure high-quality food
- **Speed**: Fast delivery times with real-time tracking
- **Reliability**: Consistent service you can count on
- **Innovation**: Continuously improving our platform and services

## Contact Us

For any questions or support, please contact us through our support channels in the app.`,
          type: 'customer',
          createdAt: '15 May 2025',
          updatedAt: '15 May 2025',
          slug: 'about-us',
          isActive: true,
          author: 'Admin'
        },
        '2': {
          id: '2',
          title: 'Privacy Policy',
          content: `# Privacy Policy

Last updated: May 15, 2025

## Information We Collect

We collect information you provide directly to us, such as when you create an account, place an order, or contact us for support.

### Personal Information
- Name and contact information
- Delivery address
- Payment information (processed securely)
- Order history and preferences

### Usage Information
- App usage data
- Device information
- Location data (for delivery purposes)

## How We Use Your Information

We use the information we collect to:
- Process and fulfill your orders
- Provide customer support
- Improve our services
- Send important updates and notifications

## Information Sharing

We do not sell your personal information. We may share information with:
- Restaurant partners (for order fulfillment)
- Delivery drivers (for delivery purposes)
- Payment processors (for transaction processing)

## Data Security

We implement appropriate security measures to protect your personal information against unauthorized access, alteration, disclosure, or destruction.

## Your Rights

You have the right to:
- Access your personal information
- Correct inaccurate information
- Delete your account and data
- Opt-out of marketing communications

## Contact Us

If you have questions about this Privacy Policy, please contact us through the app.`,
          type: 'customer',
          createdAt: '15 May 2025',
          updatedAt: '15 May 2025',
          slug: 'privacy-policy',
          isActive: true,
          author: 'Admin'
        },
        '3': {
          id: '3',
          title: 'Terms & Conditions',
          content: `# Terms & Conditions

Last updated: May 15, 2025

## Acceptance of Terms

By using Classy App, you agree to be bound by these Terms and Conditions.

## Use of Service

### Eligibility
- You must be at least 18 years old to use our service
- You must provide accurate and complete information
- You are responsible for maintaining account security

### Prohibited Uses
You may not use our service to:
- Violate any laws or regulations
- Infringe on others' rights
- Transmit harmful or malicious content
- Interfere with the service's operation

## Orders and Payments

### Ordering
- Orders are subject to restaurant availability
- Prices may vary and are subject to change
- Delivery times are estimates

### Payment
- Payment is required at the time of order
- We accept various payment methods
- Refunds are processed according to our refund policy

### Cancellation
- Orders can be cancelled within a limited time window
- Restaurant-prepared orders may not be cancellable
- Refunds are subject to our cancellation policy

## Delivery

### Delivery Areas
- Service is available in designated areas
- Delivery times vary by location
- Additional fees may apply for remote areas

### Driver Responsibilities
- Drivers are independent contractors
- Drivers are responsible for safe delivery
- Drivers must follow food safety guidelines

## Limitation of Liability

Classy App is not liable for:
- Food quality or safety issues
- Delivery delays beyond our control
- Driver conduct or behavior
- Technical issues or service interruptions

## Changes to Terms

We may update these Terms and Conditions at any time. Continued use of the service constitutes acceptance of updated terms.

## Contact Information

For questions about these Terms and Conditions, please contact us through the app.`,
          type: 'customer',
          createdAt: '15 May 2025',
          updatedAt: '15 May 2025',
          slug: 'terms-conditions',
          isActive: true,
          author: 'Admin'
        },
        '4': {
          id: '4',
          title: 'Driver Guidelines',
          content: `# Driver Guidelines

## Getting Started

### Requirements
- Valid driver's license
- Vehicle registration and insurance
- Clean driving record
- Smartphone with GPS capability

### Application Process
1. Complete online application
2. Upload required documents
3. Pass background check
4. Attend orientation session

## Delivery Standards

### Professional Conduct
- Always be polite and professional
- Maintain clean and presentable appearance
- Follow delivery instructions carefully
- Handle food with care

### Time Management
- Arrive at restaurants on time
- Follow efficient delivery routes
- Update order status promptly
- Communicate delays with customers

### Safety Guidelines
- Follow all traffic laws
- Never drive under the influence
- Maintain vehicle in good condition
- Report accidents immediately

## Earnings and Payments

### Payment Schedule
- Weekly payments every Friday
- Direct deposit to your bank account
- Detailed earnings statements provided

### Earnings Factors
- Base delivery fee
- Distance bonuses
- Peak time multipliers
- Customer tips

## Support and Resources

### Customer Support
- 24/7 driver support hotline
- In-app chat support
- Regular driver meetings

### Resources
- Driver training materials
- Safety guidelines
- Best practices guide
- Community forums

## Performance Standards

### Metrics Tracked
- Delivery completion rate
- Customer ratings
- On-time delivery percentage
- Professional conduct

### Consequences
- Excellent performance: Bonus opportunities
- Poor performance: Additional training required
- Serious violations: Account suspension

## Contact Us

For driver support, contact us through the driver app or call our driver hotline.`,
          type: 'driver',
          createdAt: '15 May 2025',
          updatedAt: '15 May 2025',
          slug: 'driver-guidelines',
          isActive: true,
          author: 'Admin'
        },
        '5': {
          id: '5',
          title: 'Safety Procedures',
          content: `# Safety Procedures

## Personal Safety

### Before Delivery
- Check vehicle condition before starting
- Ensure phone is charged and GPS is working
- Inform someone of your delivery route
- Carry personal safety equipment

### During Delivery
- Stay alert and aware of surroundings
- Avoid poorly lit or dangerous areas
- Trust your instincts - if something feels wrong, leave
- Keep vehicle locked when away

### Emergency Procedures
- Call 911 for emergencies
- Contact driver support for non-emergency issues
- Report suspicious activities immediately
- Document incidents with photos when safe

## Food Safety

### Temperature Control
- Use insulated bags for hot food
- Use coolers for cold items
- Monitor temperature during transport
- Deliver food promptly

### Hygiene Standards
- Wash hands regularly
- Keep delivery bags clean
- Separate raw and cooked foods
- Follow restaurant packaging instructions

### Contamination Prevention
- Avoid cross-contamination
- Handle food with clean hands
- Use proper storage containers
- Report damaged packaging

## Vehicle Safety

### Pre-Trip Inspection
- Check brakes, lights, and signals
- Ensure tires are properly inflated
- Test horn and wipers
- Verify insurance and registration

### Driving Safety
- Follow speed limits
- Maintain safe following distance
- Use turn signals properly
- Avoid distracted driving

### Weather Considerations
- Adjust driving for conditions
- Use appropriate safety equipment
- Consider postponing deliveries in severe weather
- Follow local weather advisories

## Incident Reporting

### What to Report
- Accidents or near-misses
- Customer complaints
- Equipment malfunctions
- Safety hazards

### How to Report
- Use the driver app incident reporting feature
- Call driver support hotline
- Document with photos when possible
- Follow up as required

## Training and Certification

### Required Training
- Food safety certification
- Defensive driving course
- Customer service training
- Platform orientation

### Ongoing Education
- Regular safety updates
- Best practices workshops
- New feature training
- Performance reviews

## Support Resources

### Emergency Contacts
- 911 for emergencies
- Driver support: 24/7 hotline
- Insurance company contact
- Local authorities

### Safety Resources
- Driver safety manual
- Emergency procedures guide
- Local safety resources
- Peer support network`,
          type: 'driver',
          createdAt: '15 May 2025',
          updatedAt: '15 May 2025',
          slug: 'safety-procedures',
          isActive: true,
          author: 'Admin'
        },
        '6': {
          id: '6',
          title: 'Partner Agreement',
          content: `# Partner Agreement

## Partnership Overview

### Benefits of Partnership
- Increased customer reach
- Marketing support
- Analytics and insights
- Dedicated account manager

### Partnership Levels
- **Basic**: Standard listing and basic features
- **Premium**: Enhanced visibility and marketing tools
- **Enterprise**: Custom solutions and priority support

## Restaurant Requirements

### Operational Standards
- Maintain food quality and safety standards
- Provide accurate menu information
- Meet delivery time commitments
- Handle customer complaints professionally

### Technical Requirements
- Point of sale integration capability
- Reliable internet connection
- Smartphone or tablet for order management
- Staff training on platform use

### Legal Compliance
- Valid business license
- Food service permits
- Health department certifications
- Insurance coverage

## Commission and Fees

### Commission Structure
- Base commission rate: 15%
- Premium partnership: 12%
- Enterprise partnership: 10%
- Volume discounts available

### Payment Terms
- Weekly payment processing
- Direct deposit to restaurant account
- Detailed earnings reports
- Transparent fee structure

### Additional Fees
- Payment processing fees
- Marketing campaign costs
- Premium feature subscriptions
- Custom integration fees

## Marketing Support

### Platform Marketing
- Featured restaurant placements
- Search result optimization
- Promotional campaign support
- Customer review management

### Co-marketing Opportunities
- Joint promotional campaigns
- Social media collaborations
- Email marketing integration
- Local event partnerships

## Performance Metrics

### Key Performance Indicators
- Order completion rate
- Customer satisfaction scores
- Delivery time accuracy
- Menu accuracy

### Performance Reviews
- Monthly performance reports
- Quarterly business reviews
- Annual partnership assessments
- Continuous improvement planning

## Termination and Renewal

### Partnership Duration
- Initial term: 12 months
- Automatic renewal unless terminated
- 30-day notice for termination
- Performance-based termination rights

### Termination Conditions
- Breach of agreement terms
- Failure to meet performance standards
- Non-payment of fees
- Mutual agreement

## Support and Training

### Onboarding Support
- Account setup assistance
- Menu upload guidance
- Staff training sessions
- Technical integration support

### Ongoing Support
- Dedicated account manager
- 24/7 technical support
- Regular business reviews
- Marketing consultation

## Contact Information

For partnership inquiries and support, contact our partnership team through the vendor app or email.`,
          type: 'vendor',
          createdAt: '15 May 2025',
          updatedAt: '15 May 2025',
          slug: 'partner-agreement',
          isActive: true,
          author: 'Admin'
        },
        '7': {
          id: '7',
          title: 'Menu Guidelines',
          content: `# Menu Guidelines

## Menu Setup

### Required Information
- Complete menu items with descriptions
- Accurate pricing for all items
- High-quality food photos
- Allergen information

### Menu Categories
- Organize items by category (appetizers, mains, desserts, etc.)
- Use clear, descriptive category names
- Maintain logical order
- Include category descriptions

### Item Descriptions
- Detailed ingredient lists
- Preparation methods
- Serving sizes
- Special dietary information

## Pricing Guidelines

### Pricing Structure
- Include all applicable taxes
- Set competitive market prices
- Consider delivery costs in pricing
- Regular price reviews and updates

### Promotional Pricing
- Clear start and end dates
- Minimum order requirements
- Combination restrictions
- Customer communication

### Price Updates
- 24-hour advance notice for price changes
- Clear communication to customers
- Platform notification system
- Historical price tracking

## Food Photography

### Photo Requirements
- High-resolution images (minimum 800x600px)
- Good lighting and composition
- Accurate color representation
- Multiple angles when helpful

### Photo Guidelines
- Professional food styling
- Clean, appealing presentation
- Consistent style across menu
- Regular photo updates

### Photo Restrictions
- No stock photos or generic images
- No misleading representations
- Respect intellectual property rights
- Follow platform guidelines

## Allergen Information

### Required Disclosures
- Common allergens clearly marked
- Cross-contamination warnings
- Ingredient substitutions
- Preparation method notes

### Allergen Categories
- Nuts and tree nuts
- Dairy products
- Gluten and wheat
- Shellfish and fish
- Soy products
- Eggs

### Safety Protocols
- Staff training on allergen awareness
- Separate preparation areas when possible
- Clear labeling on packaging
- Customer communication protocols

## Menu Updates

### Update Frequency
- Seasonal menu changes
- Price adjustments
- New item additions
- Discontinued items

### Update Process
- Submit changes through vendor app
- Review and approval process
- Customer notification system
- Historical menu tracking

### Emergency Updates
- Immediate availability changes
- Price corrections
- Safety-related modifications
- Platform notification system

## Quality Standards

### Food Quality
- Fresh ingredients only
- Proper storage and handling
- Consistent preparation methods
- Quality control processes

### Packaging Standards
- Appropriate containers for food type
- Temperature maintenance
- Leak-proof packaging
- Clear labeling

### Delivery Preparation
- Order assembly accuracy
- Temperature maintenance
- Packaging integrity
- Delivery instructions

## Customer Communication

### Menu Changes
- Advance notice for major changes
- Clear explanations for substitutions
- Customer preference accommodation
- Feedback collection

### Special Requests
- Customization options
- Dietary restrictions
- Portion size requests
- Special preparation instructions

## Performance Monitoring

### Menu Analytics
- Popular item tracking
- Sales performance metrics
- Customer feedback analysis
- Seasonal trend analysis

### Optimization
- Menu item performance reviews
- Pricing optimization
- Customer preference analysis
- Competitive analysis

## Support and Resources

### Menu Management Tools
- Easy-to-use vendor interface
- Bulk update capabilities
- Template management
- Performance dashboards

### Training Resources
- Menu setup tutorials
- Photography guidelines
- Pricing best practices
- Customer service training

## Contact Support

For menu management support, contact our vendor support team through the vendor app.`,
          type: 'vendor',
          createdAt: '15 May 2025',
          updatedAt: '15 May 2025',
          slug: 'menu-guidelines',
          isActive: true,
          author: 'Admin'
        }
      }

      const samplePage = samplePages[id]
      if (samplePage) {
        setContentPage(samplePage)
      } else {
        // Default content if ID not found
        setContentPage({
          id: id || 'unknown',
          title: 'Content Page',
          content: 'This content page is not available.',
          type: 'customer',
          createdAt: 'Unknown',
          updatedAt: 'Unknown',
          slug: 'unknown',
          isActive: false,
          author: 'Admin'
        })
      }
    } catch (error) {
      console.error('Error loading content page:', error)
    } finally {
      setLoading(false)
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

  if (!contentPage) {
    return (
      <div className="space-y-6">
        <div className="text-center py-12">
          <FileText className="w-12 h-12 text-gray-400 mx-auto mb-2" />
          <h3 className="text-lg font-medium text-gray-900">Content Page Not Found</h3>
          <p className="text-gray-500">The requested content page could not be found.</p>
          <button
            onClick={() => navigate('/contents')}
            className="mt-4 px-4 py-2 bg-pink-500 text-white rounded-lg hover:bg-pink-600 transition-colors"
          >
            Back to Content Pages
          </button>
        </div>
      </div>
    )
  }

  return (
    <div className="space-y-6">
      <div className="flex items-center justify-between">
        <div className="flex items-center">
          <button
            onClick={() => navigate('/contents')}
            className="flex items-center text-gray-600 hover:text-gray-900 mr-4"
          >
            <ArrowLeft className="w-4 h-4 mr-1" />
            Back to Content Pages
          </button>
          <div>
            <h1 className="text-3xl font-bold text-gray-900">{contentPage.title}</h1>
            <p className="text-gray-600 mt-1">View content page details</p>
          </div>
        </div>
        <button
          onClick={() => navigate(`/contents/${contentPage.id}/edit`)}
          className="flex items-center px-4 py-2 bg-pink-500 text-white rounded-lg hover:bg-pink-600 transition-colors"
        >
          <Edit className="w-4 h-4 mr-2" />
          Edit Page
        </button>
      </div>

      <div className="bg-white rounded-lg shadow-sm border border-gray-200 overflow-hidden">
        {/* Header */}
        <div className="px-6 py-4 border-b border-gray-200 bg-gray-50">
          <div className="flex items-center justify-between">
            <div className="flex items-center space-x-4">
              <div className="flex items-center">
                <FileText className="w-5 h-5 text-pink-600 mr-2" />
                <span className="text-lg font-semibold text-gray-900">{contentPage.title}</span>
              </div>
              <span className={`inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium ${
                contentPage.type === 'customer' ? 'bg-blue-100 text-blue-800' :
                contentPage.type === 'driver' ? 'bg-green-100 text-green-800' :
                'bg-purple-100 text-purple-800'
              }`}>
                {contentPage.type}
              </span>
              <span className={`inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium ${
                contentPage.isActive ? 'bg-green-100 text-green-800' : 'bg-red-100 text-red-800'
              }`}>
                {contentPage.isActive ? 'Active' : 'Inactive'}
              </span>
            </div>
            <div className="flex items-center space-x-6 text-sm text-gray-500">
              <div className="flex items-center">
                <Calendar className="w-4 h-4 mr-1" />
                <span>Updated: {contentPage.updatedAt}</span>
              </div>
              <div className="flex items-center">
                <User className="w-4 h-4 mr-1" />
                <span>By: {contentPage.author}</span>
              </div>
            </div>
          </div>
        </div>

        {/* Content */}
        <div className="px-6 py-8">
          <div className="prose max-w-none">
            <div 
              className="text-gray-700 leading-relaxed whitespace-pre-wrap"
              dangerouslySetInnerHTML={{ 
                __html: contentPage.content
                  .replace(/# (.*)/g, '<h1 class="text-2xl font-bold text-gray-900 mb-4">$1</h1>')
                  .replace(/## (.*)/g, '<h2 class="text-xl font-semibold text-gray-800 mb-3 mt-6">$1</h2>')
                  .replace(/### (.*)/g, '<h3 class="text-lg font-medium text-gray-800 mb-2 mt-4">$1</h3>')
                  .replace(/\*\*(.*?)\*\*/g, '<strong class="font-semibold text-gray-900">$1</strong>')
                  .replace(/\*(.*?)\*/g, '<em class="italic">$1</em>')
                  .replace(/- (.*)/g, '<li class="ml-4">• $1</li>')
                  .replace(/\n\n/g, '</p><p class="mb-4">')
                  .replace(/^(.*)$/gm, '<p class="mb-4">$1</p>')
                  .replace(/<p class="mb-4"><\/p>/g, '')
              }}
            />
          </div>
        </div>

        {/* Footer */}
        <div className="px-6 py-4 border-t border-gray-200 bg-gray-50">
          <div className="flex items-center justify-between text-sm text-gray-500">
            <div>
              <span>Slug: /{contentPage.slug}</span>
            </div>
            <div>
              <span>Created: {contentPage.createdAt}</span>
            </div>
          </div>
        </div>
      </div>
    </div>
  )
}
