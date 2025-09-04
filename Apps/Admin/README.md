# Classy Admin Dashboard

A comprehensive admin dashboard for managing the Classy multi-service platform. Built with React, TypeScript, and Tailwind CSS.

## Features

### 📊 Dashboard
- Real-time statistics and metrics
- Overview of customers, restaurants, drivers, and orders
- Quick action buttons for common tasks

### 👥 User Management
- **Customers**: View, manage, and block customer accounts
- **Restaurants**: Manage restaurant profiles, requests, and document updates
- **Drivers**: Handle driver registrations, document verification, and status management

### 📦 Order Management
- Track orders from placement to delivery
- Order status updates and management
- Detailed order information and customer data

### 💰 Financial Management
- **Payouts**: Manage driver and vendor payments
- **Earnings**: Track platform earnings and commissions
- **Tax Transactions**: Handle tax collection and payments

### 🎯 Content Management
- **Categories**: Manage food categories and classifications
- **Coupons**: Create and manage discount codes
- **Content Pages**: Edit static pages (About, Privacy Policy, Terms)
- **FAQs**: Manage frequently asked questions
- **Complaints**: Handle customer complaints and feedback
- **Contact Us**: Manage customer inquiries

### 🔧 System Configuration
- **Cloud Messaging**: Send push notifications and emails
- **App Configuration**: Configure platform settings, fees, and parameters

## Tech Stack

- **Frontend**: React 18, TypeScript, Vite
- **Styling**: Tailwind CSS
- **Icons**: Lucide React
- **Routing**: React Router DOM
- **Forms**: React Hook Form
- **Notifications**: React Hot Toast
- **HTTP Client**: Axios

## Getting Started

### Prerequisites

- Node.js 16+ 
- npm or yarn

### Installation

1. **Clone the repository**
   ```bash
   cd Apps/Admin
   ```

2. **Install dependencies**
   ```bash
   npm install
   ```

3. **Start the development server**
   ```bash
   npm run dev
   ```

4. **Open your browser**
   Navigate to `http://localhost:3000`

### Login Credentials

**Demo Account:**
- Email: `admin@classy.com`
- Password: `admin123`

## Project Structure

```
src/
├── components/          # Reusable UI components
│   ├── Layout.tsx      # Main layout wrapper
│   ├── Sidebar.tsx     # Navigation sidebar
│   └── Header.tsx      # Top header bar
├── contexts/           # React contexts
│   └── AuthContext.tsx # Authentication state
├── pages/              # Page components
│   ├── Dashboard.tsx   # Main dashboard
│   ├── Customers.tsx   # Customer management
│   ├── Restaurants.tsx # Restaurant management
│   ├── Drivers.tsx     # Driver management
│   ├── Orders.tsx      # Order management
│   ├── Payouts.tsx     # Financial payouts
│   ├── Earnings.tsx    # Earnings tracking
│   ├── TaxTransactions.tsx # Tax management
│   ├── Categories.tsx  # Category management
│   ├── Coupons.tsx     # Coupon management
│   ├── ContentPages.tsx # Content management
│   ├── Complaints.tsx  # Complaint handling
│   ├── ContactUs.tsx   # Contact inquiries
│   ├── FAQs.tsx        # FAQ management
│   ├── CloudMessaging.tsx # Notification system
│   ├── AppConfiguration.tsx # App settings
│   └── Login.tsx       # Login page
├── App.tsx             # Main app component
├── main.tsx           # App entry point
└── index.css          # Global styles
```

## Available Scripts

- `npm run dev` - Start development server
- `npm run build` - Build for production
- `npm run preview` - Preview production build
- `npm run lint` - Run ESLint

## Features Overview

### Dashboard
- Statistics cards showing key metrics
- Quick action buttons for common tasks
- Real-time data visualization

### User Management
- **Customers**: View customer details, order history, block/unblock accounts
- **Restaurants**: Manage restaurant profiles, handle registration requests, document verification
- **Drivers**: Driver registration, document management, status tracking

### Order Management
- Order tracking and status updates
- Detailed order information with items and customer data
- Delivery address and restaurant information

### Financial Management
- **Payouts**: Track pending payments to drivers and vendors
- **Earnings**: Monitor platform earnings and commissions
- **Tax**: Manage tax collection and payments

### Content Management
- **Categories**: Food category management with images
- **Coupons**: Create and manage promotional codes
- **Content Pages**: Static page management
- **FAQs**: Frequently asked questions management
- **Complaints**: Customer complaint handling
- **Contact Us**: Inquiry management

### System Features
- **Cloud Messaging**: Send notifications to users
- **App Configuration**: Platform settings and parameters

## Customization

### Styling
The dashboard uses Tailwind CSS for styling. You can customize the theme by modifying `tailwind.config.js`.

### Colors
- Primary: Orange/Yellow gradient
- Secondary: Gray tones
- Accent: Yellow for active states

### Adding New Pages
1. Create a new component in `src/pages/`
2. Add the route in `src/App.tsx`
3. Add navigation item in `src/components/Sidebar.tsx`

## API Integration

The dashboard is designed to work with a Laravel backend API. Update the API endpoints in the respective service files to connect to your backend.

## Deployment

### Build for Production
```bash
npm run build
```

The built files will be in the `dist/` directory, ready for deployment to any static hosting service.

### Environment Variables
Create a `.env` file for environment-specific configurations:

```env
VITE_API_BASE_URL=http://localhost:8000/api
VITE_APP_NAME=Classy Admin
```

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## License

This project is part of the Classy platform. All rights reserved.

## Support

For support and questions, please contact the development team or create an issue in the repository.
