const express = require('express');
const router = express.Router();
const { db } = require('../config/firebase');

// Food Categories endpoints
router.get('/categories', async (req, res) => {
  try {
    console.log('🍽️ Getting food categories...');
    
    // Get categories from Firestore
    const categoriesSnapshot = await db.collection('food_categories')
      .where('is_active', '==', true)
      .orderBy('name')
      .get();
    
    const categories = [];
    categoriesSnapshot.forEach(doc => {
      const data = doc.data();
      categories.push({
        id: doc.id,
        name: data.name,
        description: data.description || '',
        image: data.image || '',
        is_active: data.is_active ? 1 : 0,
        item_count: data.item_count || 0,
        created_at: data.created_at,
        updated_at: data.updated_at,
      });
    });
    
    // If no categories in database, create default ones
    if (categories.length === 0) {
      console.log('📝 No categories found, creating default categories...');
      await _createDefaultCategories();
      
      // Return default categories
      const defaultCategories = [
        {
          id: '1',
          name: 'Burger',
          description: 'Juicy burgers and sandwiches',
          image: '',
          is_active: 1,
          item_count: 0,
        },
        {
          id: '2',
          name: 'Pizza',
          description: 'Fresh pizzas and Italian dishes',
          image: '',
          is_active: 1,
          item_count: 0,
        },
        {
          id: '3',
          name: 'Salad',
          description: 'Fresh and healthy salads',
          image: '',
          is_active: 1,
          item_count: 0,
        },
        {
          id: '4',
          name: 'Sushi',
          description: 'Fresh sushi and Japanese cuisine',
          image: '',
          is_active: 1,
          item_count: 0,
        },
        {
          id: '5',
          name: 'Chicken',
          description: 'Grilled and fried chicken dishes',
          image: '',
          is_active: 1,
          item_count: 0,
        },
        {
          id: '6',
          name: 'Seafood',
          description: 'Fresh seafood and fish dishes',
          image: '',
          is_active: 1,
          item_count: 0,
        },
        {
          id: '7',
          name: 'Desserts',
          description: 'Sweet treats and desserts',
          image: '',
          is_active: 1,
          item_count: 0,
        },
        {
          id: '8',
          name: 'Beverages',
          description: 'Drinks and beverages',
          image: '',
          is_active: 1,
          item_count: 0,
        },
      ];
      
      return res.json({
        success: true,
        message: 'Default food categories retrieved',
        data: defaultCategories
      });
    }
    
    res.json({
      success: true,
      message: 'Food categories retrieved successfully',
      data: categories
    });
  } catch (error) {
    console.error('❌ Get food categories error:', error);
    res.status(500).json({ 
      error: 'Failed to get food categories', 
      message: error.message 
    });
  }
});

// Create default categories in database
async function _createDefaultCategories() {
  const defaultCategories = [
    {
      name: 'Burger',
      description: 'Juicy burgers and sandwiches',
      image: '',
      is_active: true,
      item_count: 0,
      created_at: new Date(),
      updated_at: new Date(),
    },
    {
      name: 'Pizza',
      description: 'Fresh pizzas and Italian dishes',
      image: '',
      is_active: true,
      item_count: 0,
      created_at: new Date(),
      updated_at: new Date(),
    },
    {
      name: 'Salad',
      description: 'Fresh and healthy salads',
      image: '',
      is_active: true,
      item_count: 0,
      created_at: new Date(),
      updated_at: new Date(),
    },
    {
      name: 'Sushi',
      description: 'Fresh sushi and Japanese cuisine',
      image: '',
      is_active: true,
      item_count: 0,
      created_at: new Date(),
      updated_at: new Date(),
    },
    {
      name: 'Chicken',
      description: 'Grilled and fried chicken dishes',
      image: '',
      is_active: true,
      item_count: 0,
      created_at: new Date(),
      updated_at: new Date(),
    },
    {
      name: 'Seafood',
      description: 'Fresh seafood and fish dishes',
      image: '',
      is_active: true,
      item_count: 0,
      created_at: new Date(),
      updated_at: new Date(),
    },
    {
      name: 'Desserts',
      description: 'Sweet treats and desserts',
      image: '',
      is_active: true,
      item_count: 0,
      created_at: new Date(),
      updated_at: new Date(),
    },
    {
      name: 'Beverages',
      description: 'Drinks and beverages',
      image: '',
      is_active: true,
      item_count: 0,
      created_at: new Date(),
      updated_at: new Date(),
    },
  ];
  
  try {
    for (const category of defaultCategories) {
      await db.collection('food_categories').add(category);
    }
    console.log('✅ Default food categories created successfully');
  } catch (error) {
    console.error('❌ Error creating default categories:', error);
  }
}

// Get category items
router.get('/categories/:categoryId/items', async (req, res) => {
  try {
    const { categoryId } = req.params;
    const { page = 1, limit = 20, sort_by = 'name', sort_order = 'asc' } = req.query;
    
    console.log(`🍽️ Getting items for category ${categoryId}...`);
    
    // Get items from Firestore
    let query = db.collection('food_items')
      .where('category_id', '==', categoryId)
      .where('is_active', '==', true);
    
    // Apply sorting
    if (sort_by === 'name') {
      query = query.orderBy('name', sort_order);
    } else if (sort_by === 'price') {
      query = query.orderBy('price', sort_order);
    } else if (sort_by === 'rating') {
      query = query.orderBy('rating', sort_order);
    }
    
    // Apply pagination
    const offset = (parseInt(page) - 1) * parseInt(limit);
    query = query.limit(parseInt(limit)).offset(offset);
    
    const itemsSnapshot = await query.get();
    
    const items = [];
    itemsSnapshot.forEach(doc => {
      const data = doc.data();
      items.push({
        id: doc.id,
        name: data.name,
        description: data.description || '',
        price: data.price || 0,
        image: data.image || '',
        rating: data.rating || 0,
        category_id: data.category_id,
        vendor_id: data.vendor_id,
        is_active: data.is_active ? 1 : 0,
        created_at: data.created_at,
        updated_at: data.updated_at,
      });
    });
    
    res.json({
      success: true,
      message: 'Category items retrieved successfully',
      data: items,
      pagination: {
        page: parseInt(page),
        limit: parseInt(limit),
        total: items.length,
      }
    });
  } catch (error) {
    console.error('❌ Get category items error:', error);
    res.status(500).json({ 
      error: 'Failed to get category items', 
      message: error.message 
    });
  }
});

// Search food items
router.get('/search', async (req, res) => {
  try {
    const { q, category, page = 1, limit = 20 } = req.query;
    
    if (!q) {
      return res.status(400).json({ error: 'Search query is required' });
    }
    
    console.log(`🔍 Searching food items for: "${q}"...`);
    
    // Get items from Firestore with search
    let query = db.collection('food_items')
      .where('is_active', '==', true);
    
    // Apply category filter if provided
    if (category) {
      query = query.where('category_id', '==', category);
    }
    
    const itemsSnapshot = await query.get();
    
    // Filter by search query (case-insensitive)
    const searchQuery = q.toLowerCase();
    const items = [];
    
    itemsSnapshot.forEach(doc => {
      const data = doc.data();
      const name = (data.name || '').toLowerCase();
      const description = (data.description || '').toLowerCase();
      
      if (name.includes(searchQuery) || description.includes(searchQuery)) {
        items.push({
          id: doc.id,
          name: data.name,
          description: data.description || '',
          price: data.price || 0,
          image: data.image || '',
          rating: data.rating || 0,
          category_id: data.category_id,
          vendor_id: data.vendor_id,
          is_active: data.is_active ? 1 : 0,
          created_at: data.created_at,
          updated_at: data.updated_at,
        });
      }
    });
    
    // Apply pagination
    const offset = (parseInt(page) - 1) * parseInt(limit);
    const paginatedItems = items.slice(offset, offset + parseInt(limit));
    
    res.json({
      success: true,
      message: 'Food search completed successfully',
      data: paginatedItems,
      pagination: {
        page: parseInt(page),
        limit: parseInt(limit),
        total: items.length,
      }
    });
  } catch (error) {
    console.error('❌ Search food error:', error);
    res.status(500).json({ 
      error: 'Failed to search food items', 
      message: error.message 
    });
  }
});

// Get top picks/favorites
router.get('/top-picks', async (req, res) => {
  try {
    const { filter, page = 1, limit = 20 } = req.query;
    
    console.log('⭐ Getting top picks...');
    
    // Get top-rated items from Firestore
    let query = db.collection('food_items')
      .where('is_active', '==', true)
      .where('rating', '>=', 4.0) // Only highly rated items
      .orderBy('rating', 'desc')
      .orderBy('name');
    
    // Apply filter if provided
    if (filter && filter !== 'All') {
      query = query.where('category_id', '==', filter);
    }
    
    // Apply pagination
    const offset = (parseInt(page) - 1) * parseInt(limit);
    query = query.limit(parseInt(limit)).offset(offset);
    
    const itemsSnapshot = await query.get();
    
    const items = [];
    itemsSnapshot.forEach(doc => {
      const data = doc.data();
      items.push({
        id: doc.id,
        name: data.name,
        description: data.description || '',
        price: data.price || 0,
        image: data.image || '',
        rating: data.rating || 0,
        category_id: data.category_id,
        vendor_id: data.vendor_id,
        is_active: data.is_active ? 1 : 0,
        created_at: data.created_at,
        updated_at: data.updated_at,
      });
    });
    
    res.json({
      success: true,
      message: 'Top picks retrieved successfully',
      data: items,
      pagination: {
        page: parseInt(page),
        limit: parseInt(limit),
        total: items.length,
      }
    });
  } catch (error) {
    console.error('❌ Get top picks error:', error);
    res.status(500).json({ 
      error: 'Failed to get top picks', 
      message: error.message 
    });
  }
});

module.exports = router;
