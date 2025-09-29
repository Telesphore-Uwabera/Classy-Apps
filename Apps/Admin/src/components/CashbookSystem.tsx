import React, { useState, useEffect } from 'react';
import { collection, query, where, orderBy, getDocs, updateDoc, doc } from 'firebase/firestore';
import { db } from '../config/firebase';

interface Payment {
  id: string;
  orderId: string;
  customerId: string;
  providerId: string;
  providerType: 'driver' | 'vendor' | 'restaurant';
  amount: number;
  currency: string;
  paymentMethod: 'cash' | 'mobile_money' | 'card' | 'eversend';
  status: 'pending' | 'processing' | 'completed' | 'failed' | 'cancelled' | 'refunded';
  commission: number;
  processingFee: number;
  netAmount: number;
  settlementStatus: 'pending' | 'processing' | 'completed' | 'failed';
  createdAt: Date;
  updatedAt: Date;
}

interface ProviderCommission {
  id: string;
  providerId: string;
  providerType: 'driver' | 'vendor' | 'restaurant';
  amount: number;
  status: 'pending' | 'settled' | 'failed';
  settlementId?: string;
  createdAt: Date;
  updatedAt: Date;
}

interface Settlement {
  id: string;
  providerId: string;
  providerType: 'driver' | 'vendor' | 'restaurant';
  amount: number;
  settlementMethod: 'mobile_money' | 'bank_transfer';
  accountDetails: string;
  status: 'pending' | 'processing' | 'completed' | 'failed';
  createdAt: Date;
  updatedAt: Date;
}

interface CashbookStats {
  totalSales: number;
  totalCommission: number;
  totalProcessingFees: number;
  netRevenue: number;
  cashSales: number;
  mobileMoneySales: number;
  cardSales: number;
  eversendSales: number;
  pendingCommissions: number;
  settledCommissions: number;
}

const CashbookSystem: React.FC = () => {
  const [payments, setPayments] = useState<Payment[]>([]);
  const [commissions, setCommissions] = useState<ProviderCommission[]>([]);
  const [settlements, setSettlements] = useState<Settlement[]>([]);
  const [stats, setStats] = useState<CashbookStats>({
    totalSales: 0,
    totalCommission: 0,
    totalProcessingFees: 0,
    netRevenue: 0,
    cashSales: 0,
    mobileMoneySales: 0,
    cardSales: 0,
    eversendSales: 0,
    pendingCommissions: 0,
    settledCommissions: 0,
  });
  const [loading, setLoading] = useState(true);
  const [selectedTab, setSelectedTab] = useState<'overview' | 'commissions' | 'settlements' | 'reports'>('overview');

  useEffect(() => {
    loadCashbookData();
  }, []);

  const loadCashbookData = async () => {
    try {
      setLoading(true);
      
      // Load payments
      const paymentsQuery = query(
        collection(db, 'payments'),
        orderBy('createdAt', 'desc')
      );
      const paymentsSnapshot = await getDocs(paymentsQuery);
      const paymentsData = paymentsSnapshot.docs.map(doc => ({
        id: doc.id,
        ...doc.data(),
        createdAt: doc.data().createdAt.toDate(),
        updatedAt: doc.data().updatedAt.toDate(),
      })) as Payment[];

      // Load commissions
      const commissionsQuery = query(
        collection(db, 'provider_commissions'),
        orderBy('createdAt', 'desc')
      );
      const commissionsSnapshot = await getDocs(commissionsQuery);
      const commissionsData = commissionsSnapshot.docs.map(doc => ({
        id: doc.id,
        ...doc.data(),
        createdAt: doc.data().createdAt.toDate(),
        updatedAt: doc.data().updatedAt.toDate(),
      })) as ProviderCommission[];

      // Load settlements
      const settlementsQuery = query(
        collection(db, 'settlements'),
        orderBy('createdAt', 'desc')
      );
      const settlementsSnapshot = await getDocs(settlementsQuery);
      const settlementsData = settlementsSnapshot.docs.map(doc => ({
        id: doc.id,
        ...doc.data(),
        createdAt: doc.data().createdAt.toDate(),
        updatedAt: doc.data().updatedAt.toDate(),
      })) as Settlement[];

      setPayments(paymentsData);
      setCommissions(commissionsData);
      setSettlements(settlementsData);

      // Calculate statistics
      calculateStats(paymentsData, commissionsData);
    } catch (error) {
      console.error('Error loading cashbook data:', error);
    } finally {
      setLoading(false);
    }
  };

  const calculateStats = (payments: Payment[], commissions: ProviderCommission[]) => {
    const totalSales = payments
      .filter(p => p.status === 'completed')
      .reduce((sum, p) => sum + p.amount, 0);

    const totalCommission = payments
      .filter(p => p.status === 'completed')
      .reduce((sum, p) => sum + p.commission, 0);

    const totalProcessingFees = payments
      .filter(p => p.status === 'completed')
      .reduce((sum, p) => sum + p.processingFee, 0);

    const netRevenue = totalCommission + totalProcessingFees;

    const cashSales = payments
      .filter(p => p.status === 'completed' && p.paymentMethod === 'cash')
      .reduce((sum, p) => sum + p.amount, 0);

    const mobileMoneySales = payments
      .filter(p => p.status === 'completed' && p.paymentMethod === 'mobile_money')
      .reduce((sum, p) => sum + p.amount, 0);

    const cardSales = payments
      .filter(p => p.status === 'completed' && p.paymentMethod === 'card')
      .reduce((sum, p) => sum + p.amount, 0);

    const eversendSales = payments
      .filter(p => p.status === 'completed' && p.paymentMethod === 'eversend')
      .reduce((sum, p) => sum + p.amount, 0);

    const pendingCommissions = commissions
      .filter(c => c.status === 'pending')
      .reduce((sum, c) => sum + c.amount, 0);

    const settledCommissions = commissions
      .filter(c => c.status === 'settled')
      .reduce((sum, c) => sum + c.amount, 0);

    setStats({
      totalSales,
      totalCommission,
      totalProcessingFees,
      netRevenue,
      cashSales,
      mobileMoneySales,
      cardSales,
      eversendSales,
      pendingCommissions,
      settledCommissions,
    });
  };

  const processSettlement = async (commissionId: string, settlementMethod: string, accountDetails: string) => {
    try {
      const commission = commissions.find(c => c.id === commissionId);
      if (!commission) return;

      // Create settlement record
      const settlementData = {
        providerId: commission.providerId,
        providerType: commission.providerType,
        amount: commission.amount,
        settlementMethod,
        accountDetails,
        status: 'pending',
        createdAt: new Date(),
        updatedAt: new Date(),
      };

      // Add settlement to Firestore
      const settlementRef = await addDoc(collection(db, 'settlements'), settlementData);

      // Update commission status
      await updateDoc(doc(db, 'provider_commissions', commissionId), {
        status: 'settled',
        settlementId: settlementRef.id,
        updatedAt: new Date(),
      });

      // Reload data
      await loadCashbookData();
    } catch (error) {
      console.error('Error processing settlement:', error);
    }
  };

  const markCommissionAsPaid = async (commissionId: string) => {
    try {
      await updateDoc(doc(db, 'provider_commissions', commissionId), {
        status: 'settled',
        updatedAt: new Date(),
      });

      await loadCashbookData();
    } catch (error) {
      console.error('Error marking commission as paid:', error);
    }
  };

  if (loading) {
    return (
      <div className="flex items-center justify-center h-64">
        <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-blue-600"></div>
      </div>
    );
  }

  return (
    <div className="p-6">
      <div className="mb-6">
        <h1 className="text-3xl font-bold text-gray-900">Cashbook System</h1>
        <p className="text-gray-600">Manage payments, commissions, and settlements</p>
      </div>

      {/* Tabs */}
      <div className="mb-6">
        <div className="border-b border-gray-200">
          <nav className="-mb-px flex space-x-8">
            {[
              { id: 'overview', name: 'Overview' },
              { id: 'commissions', name: 'Commissions' },
              { id: 'settlements', name: 'Settlements' },
              { id: 'reports', name: 'Reports' },
            ].map((tab) => (
              <button
                key={tab.id}
                onClick={() => setSelectedTab(tab.id as any)}
                className={`py-2 px-1 border-b-2 font-medium text-sm ${
                  selectedTab === tab.id
                    ? 'border-blue-500 text-blue-600'
                    : 'border-transparent text-gray-500 hover:text-gray-700 hover:border-gray-300'
                }`}
              >
                {tab.name}
              </button>
            ))}
          </nav>
        </div>
      </div>

      {/* Overview Tab */}
      {selectedTab === 'overview' && (
        <div className="space-y-6">
          {/* Statistics Cards */}
          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
            <div className="bg-white p-6 rounded-lg shadow">
              <h3 className="text-lg font-medium text-gray-900">Total Sales</h3>
              <p className="text-3xl font-bold text-green-600">${stats.totalSales.toFixed(2)}</p>
            </div>
            <div className="bg-white p-6 rounded-lg shadow">
              <h3 className="text-lg font-medium text-gray-900">Total Commission</h3>
              <p className="text-3xl font-bold text-blue-600">${stats.totalCommission.toFixed(2)}</p>
            </div>
            <div className="bg-white p-6 rounded-lg shadow">
              <h3 className="text-lg font-medium text-gray-900">Net Revenue</h3>
              <p className="text-3xl font-bold text-purple-600">${stats.netRevenue.toFixed(2)}</p>
            </div>
            <div className="bg-white p-6 rounded-lg shadow">
              <h3 className="text-lg font-medium text-gray-900">Pending Commissions</h3>
              <p className="text-3xl font-bold text-orange-600">${stats.pendingCommissions.toFixed(2)}</p>
            </div>
          </div>

          {/* Payment Methods Breakdown */}
          <div className="bg-white p-6 rounded-lg shadow">
            <h3 className="text-lg font-medium text-gray-900 mb-4">Sales by Payment Method</h3>
            <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-4">
              <div className="text-center">
                <div className="text-2xl font-bold text-green-600">${stats.cashSales.toFixed(2)}</div>
                <div className="text-sm text-gray-600">Cash</div>
              </div>
              <div className="text-center">
                <div className="text-2xl font-bold text-blue-600">${stats.mobileMoneySales.toFixed(2)}</div>
                <div className="text-sm text-gray-600">Mobile Money</div>
              </div>
              <div className="text-center">
                <div className="text-2xl font-bold text-purple-600">${stats.cardSales.toFixed(2)}</div>
                <div className="text-sm text-gray-600">Card</div>
              </div>
              <div className="text-center">
                <div className="text-2xl font-bold text-orange-600">${stats.eversendSales.toFixed(2)}</div>
                <div className="text-sm text-gray-600">Eversend</div>
              </div>
            </div>
          </div>

          {/* Recent Payments */}
          <div className="bg-white rounded-lg shadow">
            <div className="px-6 py-4 border-b border-gray-200">
              <h3 className="text-lg font-medium text-gray-900">Recent Payments</h3>
            </div>
            <div className="overflow-x-auto">
              <table className="min-w-full divide-y divide-gray-200">
                <thead className="bg-gray-50">
                  <tr>
                    <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                      Order ID
                    </th>
                    <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                      Amount
                    </th>
                    <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                      Method
                    </th>
                    <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                      Status
                    </th>
                    <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                      Commission
                    </th>
                    <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                      Date
                    </th>
                  </tr>
                </thead>
                <tbody className="bg-white divide-y divide-gray-200">
                  {payments.slice(0, 10).map((payment) => (
                    <tr key={payment.id}>
                      <td className="px-6 py-4 whitespace-nowrap text-sm font-medium text-gray-900">
                        {payment.orderId}
                      </td>
                      <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                        ${payment.amount.toFixed(2)}
                      </td>
                      <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                        {payment.paymentMethod.replace('_', ' ').toUpperCase()}
                      </td>
                      <td className="px-6 py-4 whitespace-nowrap">
                        <span className={`inline-flex px-2 py-1 text-xs font-semibold rounded-full ${
                          payment.status === 'completed' ? 'bg-green-100 text-green-800' :
                          payment.status === 'pending' ? 'bg-yellow-100 text-yellow-800' :
                          payment.status === 'failed' ? 'bg-red-100 text-red-800' :
                          'bg-gray-100 text-gray-800'
                        }`}>
                          {payment.status.toUpperCase()}
                        </span>
                      </td>
                      <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                        ${payment.commission.toFixed(2)}
                      </td>
                      <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                        {payment.createdAt.toLocaleDateString()}
                      </td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>
          </div>
        </div>
      )}

      {/* Commissions Tab */}
      {selectedTab === 'commissions' && (
        <div className="bg-white rounded-lg shadow">
          <div className="px-6 py-4 border-b border-gray-200">
            <h3 className="text-lg font-medium text-gray-900">Provider Commissions</h3>
          </div>
          <div className="overflow-x-auto">
            <table className="min-w-full divide-y divide-gray-200">
              <thead className="bg-gray-50">
                <tr>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                    Provider ID
                  </th>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                    Type
                  </th>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                    Amount
                  </th>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                    Status
                  </th>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                    Date
                  </th>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                    Actions
                  </th>
                </tr>
              </thead>
              <tbody className="bg-white divide-y divide-gray-200">
                {commissions.map((commission) => (
                  <tr key={commission.id}>
                    <td className="px-6 py-4 whitespace-nowrap text-sm font-medium text-gray-900">
                      {commission.providerId}
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                      {commission.providerType.toUpperCase()}
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                      ${commission.amount.toFixed(2)}
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap">
                      <span className={`inline-flex px-2 py-1 text-xs font-semibold rounded-full ${
                        commission.status === 'settled' ? 'bg-green-100 text-green-800' :
                        commission.status === 'pending' ? 'bg-yellow-100 text-yellow-800' :
                        'bg-red-100 text-red-800'
                      }`}>
                        {commission.status.toUpperCase()}
                      </span>
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                      {commission.createdAt.toLocaleDateString()}
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap text-sm font-medium">
                      {commission.status === 'pending' && (
                        <button
                          onClick={() => markCommissionAsPaid(commission.id)}
                          className="text-green-600 hover:text-green-900"
                        >
                          Mark as Paid
                        </button>
                      )}
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        </div>
      )}

      {/* Settlements Tab */}
      {selectedTab === 'settlements' && (
        <div className="bg-white rounded-lg shadow">
          <div className="px-6 py-4 border-b border-gray-200">
            <h3 className="text-lg font-medium text-gray-900">Settlements</h3>
          </div>
          <div className="overflow-x-auto">
            <table className="min-w-full divide-y divide-gray-200">
              <thead className="bg-gray-50">
                <tr>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                    Provider ID
                  </th>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                    Amount
                  </th>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                    Method
                  </th>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                    Account Details
                  </th>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                    Status
                  </th>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                    Date
                  </th>
                </tr>
              </thead>
              <tbody className="bg-white divide-y divide-gray-200">
                {settlements.map((settlement) => (
                  <tr key={settlement.id}>
                    <td className="px-6 py-4 whitespace-nowrap text-sm font-medium text-gray-900">
                      {settlement.providerId}
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                      ${settlement.amount.toFixed(2)}
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                      {settlement.settlementMethod.replace('_', ' ').toUpperCase()}
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                      {settlement.accountDetails}
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap">
                      <span className={`inline-flex px-2 py-1 text-xs font-semibold rounded-full ${
                        settlement.status === 'completed' ? 'bg-green-100 text-green-800' :
                        settlement.status === 'pending' ? 'bg-yellow-100 text-yellow-800' :
                        settlement.status === 'processing' ? 'bg-blue-100 text-blue-800' :
                        'bg-red-100 text-red-800'
                      }`}>
                        {settlement.status.toUpperCase()}
                      </span>
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                      {settlement.createdAt.toLocaleDateString()}
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        </div>
      )}

      {/* Reports Tab */}
      {selectedTab === 'reports' && (
        <div className="space-y-6">
          <div className="bg-white p-6 rounded-lg shadow">
            <h3 className="text-lg font-medium text-gray-900 mb-4">Financial Summary</h3>
            <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
              <div>
                <h4 className="font-medium text-gray-900 mb-2">Revenue Breakdown</h4>
                <div className="space-y-2">
                  <div className="flex justify-between">
                    <span>Total Sales:</span>
                    <span className="font-medium">${stats.totalSales.toFixed(2)}</span>
                  </div>
                  <div className="flex justify-between">
                    <span>Commissions:</span>
                    <span className="font-medium text-green-600">${stats.totalCommission.toFixed(2)}</span>
                  </div>
                  <div className="flex justify-between">
                    <span>Processing Fees:</span>
                    <span className="font-medium text-blue-600">${stats.totalProcessingFees.toFixed(2)}</span>
                  </div>
                  <div className="flex justify-between border-t pt-2">
                    <span className="font-medium">Net Revenue:</span>
                    <span className="font-bold text-purple-600">${stats.netRevenue.toFixed(2)}</span>
                  </div>
                </div>
              </div>
              <div>
                <h4 className="font-medium text-gray-900 mb-2">Commission Status</h4>
                <div className="space-y-2">
                  <div className="flex justify-between">
                    <span>Pending:</span>
                    <span className="font-medium text-orange-600">${stats.pendingCommissions.toFixed(2)}</span>
                  </div>
                  <div className="flex justify-between">
                    <span>Settled:</span>
                    <span className="font-medium text-green-600">${stats.settledCommissions.toFixed(2)}</span>
                  </div>
                </div>
              </div>
            </div>
          </div>

          <div className="bg-white p-6 rounded-lg shadow">
            <h3 className="text-lg font-medium text-gray-900 mb-4">Export Options</h3>
            <div className="flex space-x-4">
              <button className="bg-blue-600 text-white px-4 py-2 rounded hover:bg-blue-700">
                Export to Excel
              </button>
              <button className="bg-red-600 text-white px-4 py-2 rounded hover:bg-red-700">
                Export to PDF
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
};

export default CashbookSystem;
