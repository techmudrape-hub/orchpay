import { useState, useEffect } from 'react'
import { useNavigate, useLocation } from 'react-router-dom'
import { Button } from '@/components/ui/button'
import { Input } from '@/components/ui/input'
import { Label } from '@/components/ui/label'
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card'
import { Lock, User, Store } from 'lucide-react'
import { toast } from 'sonner'
import clientAPI from '@/api/client_api'
import { usePageTitle } from '@/hooks/usePageTitle'

export default function Login() {
  usePageTitle('Merchant Login');
  const navigate = useNavigate()
  const location = useLocation()
  const [credentials, setCredentials] = useState({ 
    merchantId: '', 
    password: ''
  })
  const [loading, setLoading] = useState(false)

  // Get the redirect path from location state or default to '/'
  const from = location.state?.from?.pathname || '/'

  useEffect(() => {
    // If already authenticated, redirect to dashboard
    if (clientAPI.isAuthenticated()) {
      navigate(from, { replace: true })
    }
  }, [navigate, from])

  const handleLogin = async (e) => {
    e.preventDefault()
    
    if (!credentials.merchantId || !credentials.password) {
      toast.error('Please fill all fields')
      return
    }

    setLoading(true)
    try {
      const response = await clientAPI.login(
        credentials.merchantId, 
        credentials.password
      )
      
      if (response.success) {
        toast.success(`Welcome back, ${response.merchantName}!`)
        // Redirect to the page they tried to visit or dashboard
        navigate(from, { replace: true })
      }
    } catch (error) {
      toast.error(error.message || 'Login failed. Please check your credentials.')
    } finally {
      setLoading(false)
    }
  }

  return (
    <div className="min-h-screen flex items-center justify-center animated-gradient p-4">
      <div className="w-full max-w-6xl grid grid-cols-1 lg:grid-cols-2 gap-8 items-center">
        {/* Left Side - Branding */}
        <div className="hidden lg:flex flex-col items-center justify-center p-12">
          <div className="mb-8 p-6 glass-effect rounded-3xl shadow-2xl">
            <img src="/orchpay_logo.png" alt="OrchPay" className="w-72 drop-shadow-2xl" />
          </div>
          <h2 className="text-4xl font-bold text-white mb-4 text-center drop-shadow-lg">
            Merchant Portal
          </h2>
          <p className="text-white/90 text-center text-lg drop-shadow-md mb-8">
            Manage your payments, settlements, and grow your business seamlessly
          </p>
          <div className="mt-8 grid grid-cols-3 gap-6 text-center">
            <div className="p-6 glass-effect rounded-2xl shadow-2xl hover:scale-105 transition-transform">
              <p className="text-4xl font-bold orchpay-gradient-text">Fast</p>
              <p className="text-sm text-gray-700 mt-2 font-medium">Settlements</p>
            </div>
            <div className="p-6 glass-effect rounded-2xl shadow-2xl hover:scale-105 transition-transform">
              <p className="text-4xl font-bold orchpay-gradient-text">24/7</p>
              <p className="text-sm text-gray-700 mt-2 font-medium">Support</p>
            </div>
            <div className="p-6 glass-effect rounded-2xl shadow-2xl hover:scale-105 transition-transform">
              <p className="text-4xl font-bold orchpay-gradient-text">Secure</p>
              <p className="text-sm text-gray-700 mt-2 font-medium">Payments</p>
            </div>
          </div>
        </div>

        {/* Right Side - Login Form */}
        <Card className="w-full shadow-2xl border-0 glass-effect backdrop-blur-xl">
          <CardHeader className="space-y-1 text-center pb-8">
            <div className="flex justify-center mb-6 lg:hidden">
              <img src="/orchpay_logo.png" alt="OrchPay" className="h-20" />
            </div>
            <div className="flex items-center justify-center gap-3 mb-2">
              <div className="p-3 orchpay-gradient-btn rounded-2xl shadow-lg">
                <Store className="h-8 w-8 text-white" />
              </div>
            </div>
            <CardTitle className="text-4xl font-bold orchpay-gradient-text">
              Merchant Login
            </CardTitle>
            <CardDescription className="text-base text-gray-600">
              Enter your credentials to access your merchant dashboard
            </CardDescription>
          </CardHeader>
          <CardContent>
            <form onSubmit={handleLogin} className="space-y-6">
              <div className="space-y-2">
                <Label htmlFor="merchantId" className="text-gray-700 font-semibold">Merchant ID</Label>
                <div className="relative">
                  <User className="absolute left-3 top-1/2 -translate-y-1/2 h-5 w-5 text-purple-400" />
                  <Input
                    id="merchantId"
                    type="text"
                    placeholder="Enter Merchant ID"
                    value={credentials.merchantId}
                    onChange={(e) => setCredentials({ ...credentials, merchantId: e.target.value })}
                    className="pl-10 h-12 bg-white/70 border-purple-200 focus:border-purple-400 rounded-xl shadow-sm"
                    required
                    disabled={loading}
                  />
                </div>
              </div>

              <div className="space-y-2">
                <Label htmlFor="password" className="text-gray-700 font-semibold">Password</Label>
                <div className="relative">
                  <Lock className="absolute left-3 top-1/2 -translate-y-1/2 h-5 w-5 text-purple-400" />
                  <Input
                    id="password"
                    type="password"
                    placeholder="••••••••"
                    value={credentials.password}
                    onChange={(e) => setCredentials({ ...credentials, password: e.target.value })}
                    className="pl-10 h-12 bg-white/70 border-purple-200 focus:border-purple-400 rounded-xl shadow-sm"
                    required
                    disabled={loading}
                  />
                </div>
              </div>
              
              <div className="flex items-center justify-between text-sm">
                <label className="flex items-center gap-2 cursor-pointer">
                  <input type="checkbox" className="rounded border-purple-300 text-purple-600 focus:ring-purple-500" disabled={loading} />
                  <span className="text-gray-600 font-medium">Remember me</span>
                </label>
              </div>

              <Button 
                type="submit" 
                disabled={loading}
                className="w-full h-12 orchpay-gradient-btn text-white font-semibold rounded-xl shadow-lg hover:shadow-2xl transition-all disabled:opacity-50"
              >
                {loading ? 'Signing In...' : 'Sign In to Dashboard'}
              </Button>
            </form>

            <div className="mt-6 text-center text-sm text-gray-600">
              Need help?{' '}
              <a href="#" className="orchpay-gradient-text hover:opacity-80 font-semibold">
                Contact Support
              </a>
            </div>
          </CardContent>
        </Card>
      </div>
    </div>
  )
}
