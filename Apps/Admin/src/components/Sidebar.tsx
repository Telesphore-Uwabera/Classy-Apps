import { Link, useLocation } from 'react-router-dom'
import { 
  LayoutDashboard, 
  Users, 
  Building2, 
  Car, 
  ShoppingCart, 
  Wallet, 
  TrendingUp, 
  Receipt, 
  Tag, 
  Gift, 
  FileText, 
  MessageSquare, 
  HelpCircle, 
  Cloud, 
  Settings,
  X,
  ChevronDown,
  Star,
  FileCheck
} from 'lucide-react'
import { useState } from 'react'

interface SidebarProps {
  isOpen: boolean
  onClose: () => void
}

interface MenuItem {
  name: string
  href: string
  icon: React.ComponentType<any>
  children?: MenuItem[]
}

const menuItems: MenuItem[] = [
  { name: 'Dashboard', href: '/', icon: LayoutDashboard },
  { name: 'Customers', href: '/customers', icon: Users },
  { name: 'Quick Picks', href: '/quick-picks', icon: Star },
  { name: 'Restaurants', href: '/restaurants', icon: Building2 },
  { name: 'Restaurants Requested', href: '/restaurants-requested', icon: Building2 },
  { name: 'Restaurants Docs Updated', href: '/restaurants-docs-updated', icon: FileCheck },
  { name: 'Drivers', href: '/drivers', icon: Car },
  { name: 'Drivers Requested', href: '/drivers-requested', icon: Car },
  { name: 'Drivers Docs Updated', href: '/drivers-docs-updated', icon: FileCheck },
  { name: 'Categories', href: '/categories', icon: Tag },
  { name: 'Orders', href: '/orders', icon: ShoppingCart },
  { name: 'Payouts', href: '/payouts', icon: Wallet },
  { name: 'Earnings', href: '/earnings', icon: TrendingUp },
  { name: 'Tax Transactions', href: '/tax', icon: Receipt },
  { name: 'Coupons', href: '/coupons', icon: Gift },
]

const managementItems: MenuItem[] = [
  { name: 'Content Pages', href: '/contents', icon: FileText },
  { name: 'Complaints', href: '/complaints', icon: MessageSquare },
  { name: 'Contact Us', href: '/contact-us', icon: MessageSquare },
  { name: 'FAQs', href: '/faqs', icon: HelpCircle },
  { name: 'Cloud Messaging', href: '/cloud-messaging', icon: Cloud },
  { name: 'App Configuration', href: '/app-configuration', icon: Settings },
]

export default function Sidebar({ isOpen, onClose }: SidebarProps) {
  const location = useLocation()
  const [expandedItems, setExpandedItems] = useState<string[]>([])

  const toggleExpanded = (itemName: string) => {
    setExpandedItems(prev => 
      prev.includes(itemName) 
        ? prev.filter(name => name !== itemName)
        : [...prev, itemName]
    )
  }

  const isActive = (href: string) => {
    if (href === '/') {
      return location.pathname === '/'
    }
    return location.pathname.startsWith(href)
  }

  const renderMenuItem = (item: MenuItem) => {
    const Icon = item.icon
    const active = isActive(item.href)
    
    return (
      <li key={item.name}>
        <Link
          to={item.href}
          className={`flex items-center px-4 py-3 text-sm font-medium rounded-lg transition-colors ${
            active
              ? 'bg-pink-100 text-pink-800 border-r-2 border-pink-500'
              : 'text-gray-700 hover:bg-gray-100'
          }`}
          onClick={onClose}
        >
          <Icon className="w-5 h-5 mr-3" />
          {item.name}
        </Link>
      </li>
    )
  }

  return (
    <>
      {/* Mobile overlay */}
      {isOpen && (
        <div 
          className="fixed inset-0 z-40 bg-gray-600 bg-opacity-75 lg:hidden"
          onClick={onClose}
        />
      )}
      
      {/* Sidebar */}
      <div className={`fixed inset-y-0 left-0 z-50 w-64 bg-white shadow-lg transform transition-transform duration-300 ease-in-out lg:translate-x-0 lg:static lg:inset-0 ${
        isOpen ? 'translate-x-0' : '-translate-x-full'
      }`}>
        <div className="flex items-center justify-between h-16 px-4 border-b border-gray-200">
          <div className="flex items-center">
            <img src="/logo.png" alt="Classy Admin Logo" className="h-8 w-auto" />
            <span className="ml-2 text-xl font-bold text-gray-800">Classy Admin</span>
          </div>
          <button
            onClick={onClose}
            className="lg:hidden p-2 rounded-md text-gray-400 hover:text-gray-600 hover:bg-gray-100"
          >
            <X className="w-5 h-5" />
          </button>
        </div>
        
        <div className="flex flex-col h-full">
          
          <nav className="flex-1 px-4 space-y-2 overflow-y-auto">
            <div>
              <h3 className="px-3 text-xs font-semibold text-gray-500 uppercase tracking-wider mb-2">
                Main Menu
              </h3>
              <ul className="space-y-1">
                {menuItems.map(renderMenuItem)}
              </ul>
            </div>
            
            <div className="pt-4">
              <h3 className="px-3 text-xs font-semibold text-gray-500 uppercase tracking-wider mb-2">
                Management
              </h3>
              <ul className="space-y-1">
                {managementItems.map(renderMenuItem)}
              </ul>
            </div>
          </nav>
        </div>
      </div>
    </>
  )
}
