import { useState } from 'react'
import { useNavigate } from 'react-router-dom'
import { Button } from '@/components/ui/button'
import { Input } from '@/components/ui/input'
import { Label } from '@/components/ui/label'
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card'
import { Lock, User, Shield, CheckCircle, Users, BarChart3 } from 'lucide-react'
import { toast } from 'sonner'
import adminAPI from '@/api/admin_api'
import { usePageTitle } from '@/hooks/usePageTitle'

export default function Login() {
  usePageTitle('Admin Login');
  const navigate = useNavigate()
  const [credentials, setCredentials] = useState({
    adminId: '',
    password: ''
  })
  const [loading, setLoading] = useState(false)

  const handleLogin = async (e) => {
    e.preventDefault()

    if (!credentials.adminId || !credentials.password) {
      toast.error('Please fill all fields')
      return
    }

    setLoading(true)
    try {
      const response = await adminAPI.login(
        credentials.adminId,
        credentials.password
      )

      if (response.success) {
        toast.success('Login successful! Welcome back.')
        navigate('/')
      }
    } catch (error) {
      toast.error(error.message || 'Login failed. Please try again.')
      setCredentials({ ...credentials, password: '' })
    } finally {
      setLoading(false)
    }
  }

  return (
    <div className="min-h-screen flex items-center justify-center bg-gradient-to-br from-gray-50 via-white to-purple-50 p-4">
      <div className="w-full max-w-5xl grid grid-cols-1 lg:grid-cols-2 gap-0 items-stretch shadow-2xl rounded-2xl overflow-hidden">
        {/* Left Side - Compact Admin Features */}
        <div className="hidden lg:flex flex-col justify-between p-8 bg-gradient-to-br from-purple-600 via-indigo-600 to-blue-600">
          <div>
            <div className="flex items-center gap-2 mb-6">
              <div className="w-10 h-10 bg-white/20 backdrop-blur-sm rounded-lg flex items-center justify-center">
                <Shield className="h-6 w-6 text-white" />
              </div>
              <span className="text-white font-semibold text-lg">Admin Portal</span>
            </div>

            <div className="inline-block bg-white rounded-2xl p-4 mb-6 shadow-xl">
              <img src="/orchpay_logo.png" alt="OrchPay" className="h-12" />
            </div>

            <h1 className="text-3xl font-bold text-white mb-3 leading-tight">
              Powerful Admin
              <br />
              Dashboard
            </h1>
            <p className="text-white/90 text-sm mb-8 leading-relaxed">
              Complete control over your payment ecosystem with advanced tools and real-time insights.
            </p>

            <div className="space-y-4">
              <div className="flex items-start gap-3">
                <div className="flex-shrink-0 w-8 h-8 bg-white/10 backdrop-blur-sm rounded-lg flex items-center justify-center">
                  <CheckCircle className="h-4 w-4 text-white" />
                </div>
                <div>
                  <h3 className="text-white font-semibold text-sm mb-0.5">Complete Transaction Control</h3>
                  <p className="text-white/70 text-xs">Monitor and manage all transactions in real-time</p>
                </div>
              </div>

              <div className="flex items-start gap-3">
                <div className="flex-shrink-0 w-8 h-8 bg-white/10 backdrop-blur-sm rounded-lg flex items-center justify-center">
                  <Users className="h-4 w-4 text-white" />
                </div>
                <div>
                  <h3 className="text-white font-semibold text-sm mb-0.5">Merchant Management</h3>
                  <p className="text-white/70 text-xs">Onboard and manage merchant accounts effortlessly</p>
                </div>
              </div>

              <div className="flex items-start gap-3">
                <div className="flex-shrink-0 w-8 h-8 bg-white/10 backdrop-blur-sm rounded-lg flex items-center justify-center">
                  <BarChart3 className="h-4 w-4 text-white" />
                </div>
                <div>
                  <h3 className="text-white font-semibold text-sm mb-0.5">Advanced Analytics</h3>
                  <p className="text-white/70 text-xs">Comprehensive reports and insights</p>
                </div>
              </div>
            </div>
          </div>

          <div className="pt-6 mt-6 border-t border-white/20">
            <div className="grid grid-cols-3 gap-4 text-center">
              <div>
                <p className="text-2xl font-bold text-white">99.9%</p>
                <p className="text-xs text-white/70">Uptime</p>
              </div>
              <div>
                <p className="text-2xl font-bold text-white">24/7</p>
                <p className="text-xs text-white/70">Support</p>
              </div>
              <div>
                <p className="text-2xl font-bold text-white">100%</p>
                <p className="text-xs text-white/70">Secure</p>
              </div>
            </div>
          </div>
        </div>

        {/* Right Side - Compact Login Form */}
        <div className="flex items-center justify-center p-8 bg-white">
          <div className="w-full max-w-sm">
            {/* Mobile Logo */}
            <div className="flex justify-center mb-6 lg:hidden">
              <img src="/orchpay_logo.png" alt="OrchPay" className="h-12" />
            </div>

            <div className="text-center mb-6">
              <div className="inline-flex items-center justify-center w-14 h-14 orchpay-gradient-btn rounded-xl shadow-lg mb-3">
                <Shield className="h-7 w-7 text-white" />
              </div>
              <h2 className="text-2xl font-bold text-gray-900 mb-1">
                Admin Login
              </h2>
              <p className="text-gray-600 text-sm">
                Enter your credentials to access the admin panel
              </p>
            </div>

            <form onSubmit={handleLogin} className="space-y-4">
              <div className="space-y-1.5">
                <Label htmlFor="adminId" className="text-gray-700 font-semibold text-xs">
                  Admin ID
                </Label>
                <div className="relative">
                  <User className="absolute left-3 top-1/2 -translate-y-1/2 h-4 w-4 text-gray-400" />
                  <Input
                    id="adminId"
                    type="text"
                    placeholder="Enter your admin ID"
                    value={credentials.adminId}
                    onChange={(e) => setCredentials({ ...credentials, adminId: e.target.value })}
                    className="pl-9 h-10 text-sm bg-gray-50 border-gray-300 focus:border-purple-500 focus:ring-2 focus:ring-purple-200 rounded-lg"
                    required
                    disabled={loading}
                  />
                </div>
              </div>

              <div className="space-y-1.5">
                <Label htmlFor="password" className="text-gray-700 font-semibold text-xs">
                  Password
                </Label>
                <div className="relative">
                  <Lock className="absolute left-3 top-1/2 -translate-y-1/2 h-4 w-4 text-gray-400" />
                  <Input
                    id="password"
                    type="password"
                    placeholder="Enter your password"
                    value={credentials.password}
                    onChange={(e) => setCredentials({ ...credentials, password: e.target.value })}
                    className="pl-9 h-10 text-sm bg-gray-50 border-gray-300 focus:border-purple-500 focus:ring-2 focus:ring-purple-200 rounded-lg"
                    required
                    disabled={loading}
                  />
                </div>
              </div>

              <div className="flex items-center justify-between pt-1">
                <label className="flex items-center gap-2 cursor-pointer">
                  <input
                    type="checkbox"
                    className="w-3.5 h-3.5 rounded border-gray-300 text-purple-600 focus:ring-purple-500 cursor-pointer"
                    disabled={loading}
                  />
                  <span className="text-xs text-gray-600 font-medium">
                    Remember me
                  </span>
                </label>
              </div>

              <Button
                type="submit"
                disabled={loading}
                className="w-full h-10 orchpay-gradient-btn text-white font-semibold text-sm rounded-lg shadow-lg hover:shadow-xl transition-all disabled:opacity-50 mt-5"
              >
                {loading ? (
                  <span className="flex items-center justify-center gap-2">
                    <div className="animate-spin rounded-full h-4 w-4 border-b-2 border-white"></div>
                    Signing In...
                  </span>
                ) : (
                  'Sign In to Dashboard'
                )}
              </Button>
            </form>

            <div className="mt-6 pt-4 border-t border-gray-200">
              <p className="text-center text-xs text-gray-500">
                Protected by enterprise-grade security
              </p>
            </div>
          </div>
        </div>
      </div>
    </div>
  )
}
