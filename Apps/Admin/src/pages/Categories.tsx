import { useState, useEffect } from 'react'
import { Search, Plus, Edit, Trash2, Tag } from 'lucide-react'
import { useNavigate } from 'react-router-dom'

interface Category {
  id: string
  name: string
  image: string
  createdAt: string
}

export default function Categories() {
  const navigate = useNavigate()
  const [categories, setCategories] = useState<Category[]>([
    {
      id: '1',
      name: 'Main Course',
      image: '/api/placeholder/64/64',
      createdAt: '14 Aug 2025'
    },
    {
      id: '2',
      name: 'Desserts',
      image: '/api/placeholder/64/64',
      createdAt: '26 Apr 2025'
    },
    {
      id: '3',
      name: 'Breakfast',
      image: '/api/placeholder/64/64',
      createdAt: '26 Apr 2025'
    },
    {
      id: '4',
      name: 'Burger',
      image: '/api/placeholder/64/64',
      createdAt: '26 Apr 2025'
    },
    {
      id: '5',
      name: 'Pasta',
      image: '/api/placeholder/64/64',
      createdAt: '26 Apr 2025'
    },
    {
      id: '6',
      name: 'Chicken',
      image: '/api/placeholder/64/64',
      createdAt: '26 Apr 2025'
    }
  ])

  const [searchTerm, setSearchTerm] = useState('')

  const filteredCategories = categories.filter(category =>
    category.name.toLowerCase().includes(searchTerm.toLowerCase())
  )

  const handleAddCategory = () => {
    navigate('/categories/new')
  }

  const handleEditCategory = (categoryId: string) => {
    navigate(`/categories/${categoryId}/edit`)
  }

  const handleDeleteCategory = (categoryId: string) => {
    if (window.confirm('Are you sure you want to delete this category?')) {
      setCategories(prevCategories => 
        prevCategories.filter(category => category.id !== categoryId)
      )
    }
  }

  return (
    <div className="space-y-6">
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-3xl font-bold text-gray-900">Categories</h1>
          <p className="text-gray-600 mt-1">Manage food categories and classifications</p>
        </div>
        <button
          onClick={handleAddCategory}
          className="flex items-center px-4 py-2 bg-yellow-500 text-white rounded-lg hover:bg-yellow-600 transition-colors"
        >
          <Plus className="w-4 h-4 mr-2" />
          Add
        </button>
      </div>

      {/* Search */}
      <div className="flex items-center space-x-4">
        <div className="flex-1 relative">
          <Search className="absolute left-3 top-1/2 transform -translate-y-1/2 text-gray-400 w-4 h-4" />
          <input
            type="text"
            placeholder="Search by category name"
            value={searchTerm}
            onChange={(e) => setSearchTerm(e.target.value)}
            className="w-full pl-10 pr-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-yellow-500 focus:border-yellow-500"
          />
        </div>
      </div>

      {/* Categories Table */}
      <div className="bg-white rounded-lg shadow-sm border border-gray-200 overflow-hidden">
        <div className="overflow-x-auto">
          <table className="min-w-full divide-y divide-gray-200">
            <thead className="bg-gray-50">
              <tr>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Sr. no.
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Name
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Created at
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Action
                </th>
              </tr>
            </thead>
            <tbody className="bg-white divide-y divide-gray-200">
              {filteredCategories.map((category, index) => (
                <tr key={category.id} className="hover:bg-gray-50">
                  <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                    {index + 1}
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap">
                    <div className="flex items-center">
                      <div className="w-10 h-10 bg-gray-200 rounded-full flex items-center justify-center mr-3">
                        <Tag className="w-5 h-5 text-gray-600" />
                      </div>
                      <span className="text-sm font-medium text-gray-900">{category.name}</span>
                    </div>
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                    {category.createdAt}
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap text-sm font-medium">
                    <div className="flex items-center space-x-2">
                      <button
                        onClick={() => handleEditCategory(category.id)}
                        className="w-8 h-8 bg-blue-100 text-blue-600 rounded-full flex items-center justify-center hover:bg-blue-200 transition-colors"
                      >
                        <Edit className="w-4 h-4" />
                      </button>
                      <button
                        onClick={() => handleDeleteCategory(category.id)}
                        className="w-8 h-8 bg-red-100 text-red-600 rounded-full flex items-center justify-center hover:bg-red-200 transition-colors"
                      >
                        <Trash2 className="w-4 h-4" />
                      </button>
                    </div>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </div>
    </div>
  )
}
