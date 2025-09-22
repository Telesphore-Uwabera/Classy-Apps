import { BrowserRouter as Router, Routes, Route, Navigate } from 'react-router-dom'
import { Toaster } from 'react-hot-toast'
import Layout from './components/Layout'
import Login from './pages/Login'
import Dashboard from './pages/Dashboard'
import Customers from './pages/Customers'
import QuickPicks from './pages/QuickPicks'
import QuickPicksEditor from './pages/QuickPicksEditor'
import Restaurants from './pages/Restaurants'
import RestaurantsRequested from './pages/RestaurantsRequested'
import Vendors from './pages/Vendors'
import VendorsRequested from './pages/VendorsRequested'
import VendorDetails from './pages/VendorDetails'
import RestaurantDetails from './pages/RestaurantDetails'
import RestaurantsDocsUpdated from './pages/RestaurantsDocsUpdated'
import Drivers from './pages/Drivers'
import DriversRequested from './pages/DriversRequested'
import DriverDetails from './pages/DriverDetails'
import DriversDocsUpdated from './pages/DriversDocsUpdated'
import DriverDocsDetails from './pages/DriverDocsDetails'
import Orders from './pages/Orders'
import Payouts from './pages/Payouts'
import Earnings from './pages/Earnings'
import TaxTransactions from './pages/TaxTransactions'
import Categories from './pages/Categories'
import CategoryEditor from './pages/CategoryEditor'
import Coupons from './pages/Coupons'
import ContentPages from './pages/ContentPages'
import ContentPageViewer from './pages/ContentPageViewer'
import ContentPageEditor from './pages/ContentPageEditor'
import Complaints from './pages/Complaints'
import ContactUs from './pages/ContactUs'
import FAQs from './pages/FAQs'
import FAQEditor from './pages/FAQEditor'
import CloudMessaging from './pages/CloudMessaging'
import AppConfiguration from './pages/AppConfiguration'
import FareManagement from './pages/FareManagement'
import LiveTracking from './pages/LiveTracking'
import IncidentManagement from './pages/IncidentManagement'
import Analytics from './pages/Analytics'
import Helpdesk from './pages/Helpdesk'
import { AuthProvider, useAuth } from './contexts/AuthContext'

function ProtectedRoute({ children }: { children: React.ReactNode }) {
  const { isAuthenticated } = useAuth()
  
  if (!isAuthenticated) {
    return <Navigate to="/login" replace />
  }
  
  return <>{children}</>
}

function AppRoutes() {
  return (
    <Routes>
      <Route path="/login" element={<Login />} />
      <Route path="/" element={
        <ProtectedRoute>
          <Layout />
        </ProtectedRoute>
      }>
        <Route index element={<Dashboard />} />
        <Route path="customers" element={<Customers />} />
        <Route path="quick-picks" element={<QuickPicks />} />
        <Route path="quick-picks/:id/edit" element={<QuickPicksEditor />} />
        <Route path="quick-picks/new" element={<QuickPicksEditor />} />
        <Route path="restaurants" element={<Restaurants />} />
        <Route path="restaurants-requested" element={<RestaurantsRequested />} />
        <Route path="restaurants-requested/:id/view" element={<RestaurantDetails />} />
            <Route path="vendors" element={<Vendors />} />
            <Route path="vendors-requested" element={<VendorsRequested />} />
            <Route path="vendors-requested/:id/view" element={<VendorDetails />} />
        <Route path="restaurants-docs-updated" element={<RestaurantsDocsUpdated />} />
        <Route path="drivers" element={<Drivers />} />
        <Route path="drivers-requested" element={<DriversRequested />} />
        <Route path="drivers-requested/:id/view" element={<DriverDetails />} />
        <Route path="drivers-docs-updated" element={<DriversDocsUpdated />} />
        <Route path="drivers-docs-updated/:id/view" element={<DriverDocsDetails />} />
        <Route path="orders" element={<Orders />} />
        <Route path="payouts" element={<Payouts />} />
        <Route path="earnings" element={<Earnings />} />
        <Route path="tax" element={<TaxTransactions />} />
        <Route path="categories" element={<Categories />} />
        <Route path="categories/:id/edit" element={<CategoryEditor />} />
        <Route path="categories/new" element={<CategoryEditor />} />
        <Route path="categories/add" element={<CategoryEditor />} />
        <Route path="coupons" element={<Coupons />} />
        <Route path="contents" element={<ContentPages />} />
        <Route path="contents/:id" element={<ContentPageViewer />} />
        <Route path="contents/:id/edit" element={<ContentPageEditor />} />
        <Route path="contents/add" element={<ContentPageEditor />} />
        <Route path="complaints" element={<Complaints />} />
        <Route path="contact-us" element={<ContactUs />} />
        <Route path="faqs" element={<FAQs />} />
        <Route path="faqs/:id/edit" element={<FAQEditor />} />
        <Route path="faqs/new" element={<FAQEditor />} />
        <Route path="cloud-messaging" element={<CloudMessaging />} />
        <Route path="app-configuration" element={<AppConfiguration />} />
        <Route path="fare-management" element={<FareManagement />} />
        <Route path="live-tracking" element={<LiveTracking />} />
        <Route path="incident-management" element={<IncidentManagement />} />
        <Route path="analytics" element={<Analytics />} />
        <Route path="helpdesk" element={<Helpdesk />} />
      </Route>
    </Routes>
  )
}

function App() {
  return (
    <AuthProvider>
      <Router>
        <div className="min-h-screen bg-gray-50">
          <AppRoutes />
          <Toaster 
            position="top-right"
            toastOptions={{
              duration: 4000,
              style: {
                background: '#363636',
                color: '#fff',
              },
            }}
          />
        </div>
      </Router>
    </AuthProvider>
  )
}

export default App
