# iBusiness Platform

A full-stack digital business platform built with Node.js backend API and vanilla JavaScript frontend. The backend uses Express.js, MongoDB, and Redis, while the frontend provides a modern web interface for managing products, events, orders, and user interactions.

## Table of Contents

- [Features](#features)
- [Project Structure](#project-structure)
- [Tech Stack](#tech-stack)
- [Prerequisites](#prerequisites)
- [Installation](#installation)
- [Environment Setup](#environment-setup)
- [Database Setup](#database-setup)
- [Running the Application](#running-the-application)
- [API Documentation](#api-documentation)
- [Frontend Documentation](#frontend-documentation)
- [Authentication](#authentication)
- [Database Schema](#database-schema)
- [Deployment](#deployment)
- [Testing](#testing)
- [Contributing](#contributing)
- [License](#license)

## Features

- **User Management**: Registration, authentication, role-based access control
- **Product Management**: Digital products, workshops, subscriptions, bundles
- **Event Management**: Workshops, webinars, conferences with registration
- **Order Processing**: Complete e-commerce flow with payment integration
- **Security**: JWT authentication, CSRF protection, rate limiting, input sanitization
- **Caching**: Redis-based caching for improved performance
- **Logging**: Comprehensive logging with Winston and MongoDB storage
- **File Upload**: Image processing with Sharp and Multer
- **Email Integration**: Nodemailer for transactional emails
- **Referral System**: Built-in referral tracking and rewards
- **Admin Dashboard**: Full administrative controls
- **Modern Frontend**: Vanilla JavaScript-based web interface
- **Responsive Design**: Mobile-friendly user interface

## Project Structure

```
ibusinessv2/
├── backend/                    # Node.js API server
│   ├── config/                # Configuration files
│   ├── middleware/            # Express middleware
│   ├── models/                # MongoDB models
│   ├── routes/                # API routes
│   ├── services/              # Business logic services
│   ├── utils/                 # Utility functions
│   ├── tests/                 # Test files
│   ├── logs/                  # Application logs
│   ├── server.js              # Main server file
│   ├── package.json           # Backend dependencies
│   └── .env                   # Environment variables
├── frontend/                  # Vanilla JavaScript frontend
│   ├── pages/                 # HTML pages
│   └── public/                # Static assets
│       ├── js/                # JavaScript modules
│       └── css/               # Stylesheets
├── README.md                  # Main documentation
├── README-INSTALLATION.md     # Installation guide
└── install-ibusiness.sh       # Installation script
```

## Tech Stack

### Backend
- **Runtime**: Node.js
- **Framework**: Express.js
- **Database**: MongoDB with Mongoose ODM
- **Cache**: Redis
- **Authentication**: JWT with refresh tokens
- **Security**: Helmet, CORS, CSRF protection, input sanitization
- **File Processing**: Multer, Sharp
- **Email**: Nodemailer
- **Logging**: Winston
- **Validation**: Joi
- **Testing**: Jest, Supertest

### Frontend
- **Language**: Vanilla JavaScript (ES6+)
- **Styling**: CSS3 with responsive design
- **Architecture**: Modular JavaScript with async/await
- **API Communication**: Fetch API with error handling

## Prerequisites

Before running this application, make sure you have the following installed:

- Node.js (v16 or higher)
- MongoDB (v4.4 or higher)
- Redis (v6 or higher)
- npm or yarn package manager

## Installation

1. **Clone the repository**
    ```bash
    git clone https://github.com/your-org/ibusinessv2.git
    cd ibusinessv2
    ```

2. **Install backend dependencies**
    ```bash
    cd backend
    npm install
    cd ..
    ```

3. **Set up environment variables**
    ```bash
    cp backend/.env.example backend/.env
    # Edit backend/.env with your configuration
    ```

## Environment Setup

Create a `.env` file in the `backend/` directory with the following variables:

```env
# Node Environment
NODE_ENV=development

# Server Configuration
PORT=3000

# Database Configuration
MONGODB_URI=mongodb://127.0.0.1:27017/ibusiness
MONGODB_TEST_URI=mongodb://127.0.0.1:27017/ibusiness_test

# Redis Configuration
REDIS_HOST=localhost
REDIS_PORT=6379
REDIS_PASSWORD=

# JWT Configuration
JWT_SECRET=your-super-secret-jwt-key-change-this-in-production
JWT_EXPIRES_IN=7d
JWT_REFRESH_SECRET=your-refresh-token-secret-change-this-in-production
JWT_REFRESH_EXPIRES_IN=30d

# Email Configuration
EMAIL_HOST=smtp.gmail.com
EMAIL_PORT=587
EMAIL_SECURE=false
EMAIL_USER=your-email@gmail.com
EMAIL_PASS=your-app-specific-password
EMAIL_FROM=noreply@ibusiness.id

# Security Configuration
CORS_ORIGIN=http://localhost:3000,http://localhost:3001
SESSION_SECRET=your-session-secret-change-this-in-production
CSRF_SECRET=your-csrf-secret-change-this-in-production

# File Upload Configuration
FILE_UPLOAD_PATH=./uploads
MAX_FILE_SIZE=5242880
MAX_FILES_COUNT=10

# Rate Limiting
RATE_LIMIT_WINDOW_MS=900000
RATE_LIMIT_MAX_REQUESTS=100

# Logging Configuration
LOG_LEVEL=info
LOG_FILE_PATH=./logs/app.log

# Other Configuration
BCRYPT_ROUNDS=10
API_VERSION=v1
```

## Database Setup

1. **Start MongoDB**
   ```bash
   # Using local MongoDB
   mongod

   # Or using Docker
   docker run -d -p 27017:27017 --name mongodb mongo:latest
   ```

2. **Start Redis**
   ```bash
   # Using local Redis
   redis-server

   # Or using Docker
   docker run -d -p 6379:6379 --name redis redis:latest
   ```

3. **Database will be automatically initialized** when the application starts.

## Running the Application

### Backend Development Mode

```bash
# From the project root
cd backend

# Start with nodemon (auto-restart on changes)
npm run dev

# Or start normally
npm start
```

### Frontend Development Mode

```bash
# From the project root
# Serve frontend files using a local server (e.g., using Python)
cd frontend
python3 -m http.server 8080

# Or use any static file server
# The frontend will be available at http://localhost:8080
```

### Full Stack Development

For full development, run both backend and frontend:

```bash
# Terminal 1: Backend
cd backend && npm run dev

# Terminal 2: Frontend
cd frontend && python3 -m http.server 8080
```

The backend will start on the port specified in your `.env` file (default: 3000), and the frontend on port 8080.

### Production Mode

```bash
# Backend
cd backend && npm start

# Frontend should be served by a web server (nginx, Apache, etc.)
```

## API Documentation

### Base URL
```
http://localhost:3000/api
```

## Frontend Documentation

### Frontend Structure

The frontend is built with vanilla JavaScript and consists of:

- **Pages**: HTML files in `frontend/pages/`
- **JavaScript Modules**: Organized in `frontend/public/js/`
- **Styles**: CSS files in `frontend/public/css/`
- **Assets**: Images and other static files

### Key Frontend Files

- `frontend/pages/index.html` - Landing page
- `frontend/pages/login.html` - User login
- `frontend/pages/register.html` - User registration
- `frontend/pages/dashboard.html` - User dashboard
- `frontend/public/js/api.js` - API communication utilities
- `frontend/public/js/auth/auth.js` - Authentication handling

### Frontend Development

The frontend communicates with the backend API using the Fetch API. All API calls are centralized in `api.js` for consistency and error handling.

### Building for Production

For production deployment, serve the `frontend/` directory using a web server like nginx or Apache. Ensure CORS is properly configured in the backend for cross-origin requests.

### Authentication Endpoints

#### Register User
```http
POST /api/auth/register
Content-Type: application/json

{
  "email": "user@example.com",
  "password": "SecurePass123!",
  "name": "John Doe",
  "whatsapp": "+6281234567890",
  "referredBy": "ABC123DEF" // optional
}
```

#### Login
```http
POST /api/auth/login
Content-Type: application/json

{
  "email": "user@example.com",
  "password": "SecurePass123!",
  "rememberMe": false
}
```

#### Get Current User
```http
GET /api/auth/me
Authorization: Bearer <access_token>
```

### Product Endpoints

#### List Products
```http
GET /api/products?page=1&limit=12&search=keyword&category=digital_product
```

#### Create Product
```http
POST /api/products
Authorization: Bearer <access_token>
Content-Type: multipart/form-data

{
  name: "My Digital Product",
  description: "Product description",
  price: 50000,
  type: "paid_product",
  category: "digital_product",
  image: <file>,
  images: [<files>]
}
```

### Order Endpoints

#### Create Order
```http
POST /api/orders
Authorization: Bearer <access_token>
Content-Type: application/json

{
  "items": [
    {
      "productId": "60d5ecb74b24c72b8c8b4567",
      "quantity": 1
    }
  ],
  "shippingAddress": {
    "street": "Jl. Example No. 123",
    "city": "Jakarta",
    "postalCode": "12345"
  },
  "paymentMethod": "bank_transfer"
}
```

#### List User Orders
```http
GET /api/orders?page=1&limit=10&status=completed
Authorization: Bearer <access_token>
```

### Event Endpoints

#### List Events
```http
GET /api/events?page=1&limit=12&type=workshop&isFree=true
```

#### Register for Event
```http
POST /api/events/:id/register
Authorization: Bearer <access_token>
Content-Type: application/json

{
  "specialRequests": "Vegetarian meal preference"
}
```

### Admin Endpoints

#### User Management
```http
GET /api/users?page=1&limit=10&role=user
PUT /api/users/:id
DELETE /api/users/:id
```

#### System Statistics
```http
GET /api/logs/stats/overview
GET /api/cache/stats
```

## Authentication

The API uses JWT (JSON Web Tokens) for authentication with the following flow:

1. **Registration/Login**: User provides credentials
2. **Token Generation**: Server generates access and refresh tokens
3. **Token Storage**: Tokens are stored in HTTP-only cookies
4. **Token Verification**: Each request verifies the access token
5. **Token Refresh**: When access token expires, use refresh token to get new tokens

### Authentication Headers

```http
Authorization: Bearer <access_token>
```

### CSRF Protection

For state-changing operations, include the CSRF token:

```http
X-CSRF-Token: <csrf_token>
```

Get CSRF token from:
```http
GET /api/auth/csrf-token
```

## Database Schema

### User Model
```javascript
{
  email: String (unique, required),
  password: String (hashed, select: false),
  name: String (required),
  whatsapp: String,
  avatar: String,
  role: Enum ['super_admin', 'admin', 'owner', 'manager', 'staff', 'user'],
  permissions: [String],
  emailVerified: Boolean,
  referralCode: String (unique),
  referredBy: ObjectId (ref: 'User'),
  isActive: Boolean,
  lastLogin: Date,
  createdAt: Date,
  updatedAt: Date
}
```

### Product Model
```javascript
{
  owner: ObjectId (ref: 'User', required),
  name: String (required),
  slug: String (unique),
  description: String (required),
  type: Enum ['paid_product', 'free_workshop', 'subscription', 'bundle'],
  category: String,
  price: Number,
  currency: Enum ['IDR', 'USD'],
  image: String (required),
  images: [String],
  paymentInfo: {
    bank: String,
    accountNumber: String,
    accountHolder: String
  },
  downloadLink: String,
  stock: Number,
  isActive: Boolean,
  views: Number,
  orders: Number,
  rating: {
    average: Number,
    count: Number
  },
  createdAt: Date,
  updatedAt: Date
}
```

### Order Model
```javascript
{
  orderNumber: String (unique, required),
  customer: ObjectId (ref: 'User', required),
  product: ObjectId (ref: 'Product', required),
  seller: ObjectId (ref: 'User', required),
  amount: Number (required),
  currency: String,
  paymentMethod: String,
  status: Enum ['pending', 'payment_uploaded', 'paid', 'processing', 'completed', 'cancelled', 'refunded'],
  paymentProof: {
    url: String,
    uploadedAt: Date
  },
  downloadLink: String,
  customerNotes: String,
  createdAt: Date,
  updatedAt: Date
}
```

### Event Model
```javascript
{
  organizer: ObjectId (ref: 'User', required),
  title: String (required),
  slug: String (unique),
  description: String (required),
  type: Enum ['workshop', 'webinar', 'seminar', 'training', 'conference'],
  startDate: Date (required),
  endDate: Date (required),
  locationType: Enum ['online', 'offline', 'hybrid'],
  isFree: Boolean,
  price: Number,
  maxParticipants: Number (required),
  currentParticipants: Number,
  image: String (required),
  status: Enum ['draft', 'published', 'ongoing', 'completed', 'cancelled'],
  createdAt: Date,
  updatedAt: Date
}
```

## Deployment

### Development Deployment

1. **Environment Setup**
   ```bash
   export NODE_ENV=development
   export PORT=3000
   ```

2. **Start Services**
   ```bash
   # MongoDB and Redis should be running
   npm run dev
   ```

### Production Deployment

1. **Environment Variables**
   - Set `NODE_ENV=production`
   - Configure production database URLs
   - Set secure JWT secrets
   - Configure production email settings

2. **Process Manager**
   ```bash
   # Using PM2
   npm install -g pm2
   pm2 start server.js --name "ibusiness-api"
   pm2 startup
   pm2 save
   ```

3. **Reverse Proxy (nginx)**
   ```nginx
   server {
       listen 80;
       server_name api.ibusiness.id;

       location / {
           proxy_pass http://localhost:3000;
           proxy_http_version 1.1;
           proxy_set_header Upgrade $http_upgrade;
           proxy_set_header Connection 'upgrade';
           proxy_set_header Host $host;
           proxy_set_header X-Real-IP $remote_addr;
           proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
           proxy_set_header X-Forwarded-Proto $scheme;
           proxy_cache_bypass $http_upgrade;
       }
   }
   ```

4. **SSL Certificate**
   ```bash
   # Using Let's Encrypt
   certbot --nginx -d api.ibusiness.id
   ```

## Testing

### Running Tests

```bash
# Run all tests
npm test

# Run tests with coverage
npm run test:coverage

# Run specific test file
npm test -- tests/auth.test.js
```

### Test Structure

```
backend/tests/
├── api.test.js          # API endpoint tests
├── auth.test.js         # Authentication tests
├── models/              # Model unit tests
├── integration/         # Integration tests
└── utils/              # Utility function tests
```

### Frontend Testing

Frontend code can be tested manually or with browser developer tools. For automated testing, consider using tools like:

- Cypress for end-to-end testing
- Jest for JavaScript unit tests
- Browser developer tools for debugging

### Test Database

Tests use a separate test database. Configure `MONGODB_TEST_URI` in your `.env` file.

## Postman Collection

Import the provided Postman collection for easy API testing:

1. Open Postman
2. Click "Import"
3. Select "File"
4. Choose `ibusiness-api.postman_collection.json`
5. Set environment variables:
   - `base_url`: `http://localhost:3000/api`
   - `access_token`: (will be set after login)

### Collection Structure

- **Authentication**: Login, register, token refresh
- **Users**: CRUD operations, profile management
- **Products**: Product management, search, filtering
- **Orders**: Order creation, status updates, history
- **Events**: Event management, registration
- **Admin**: Administrative functions, statistics

## Security Features

- **JWT Authentication** with refresh tokens
- **CSRF Protection** on state-changing operations
- **Rate Limiting** on authentication endpoints
- **Input Sanitization** using express-mongo-sanitize and xss-clean
- **Helmet** for security headers
- **CORS** configuration
- **Password Hashing** with bcrypt
- **Session Management** with device tracking
- **Audit Logging** for security events

## Monitoring and Logging

### Log Levels
- `error`: Error conditions
- `warn`: Warning conditions
- `info`: Informational messages
- `debug`: Debug information

### Log Storage
- **File**: `backend/logs/app.log`
- **Database**: MongoDB collection for persistent storage
- **Console**: Development mode output

### Monitoring Endpoints
```http
GET /api/logs/stats/overview          # General statistics
GET /api/logs/stats/security          # Security events
GET /api/logs/stats/performance       # Performance metrics
GET /api/cache/stats                  # Cache statistics
```

## Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

### Code Standards

- Use ESLint configuration
- Follow conventional commit messages
- Write tests for new features
- Update documentation

## Troubleshooting

### Common Issues

1. **MongoDB Connection Error**
   - Ensure MongoDB is running
   - Check connection string in `.env`
   - Verify network connectivity

2. **Redis Connection Error**
   - Ensure Redis is running on correct port
   - Check Redis configuration in `.env`

3. **Email Not Sending**
   - Verify email credentials in `.env`
   - Check SMTP server settings
   - Review email service logs

4. **File Upload Issues**
   - Ensure `backend/uploads/` directory exists and is writable
   - Check file size limits in backend configuration
   - Verify multer configuration

### Debug Mode

Enable debug logging:
```bash
DEBUG=* npm start
```

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Support

For support and questions:
- Email: support@ibusiness.id
- Documentation: [API Docs](https://api.ibusiness.id/docs)
- Issues: [GitHub Issues](https://github.com/your-org/ibusinessv2/issues)

---

**iBusiness.id** - Empowering Digital Businesses