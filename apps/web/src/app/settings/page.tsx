'use client'

import { useState } from 'react'

export default function SettingsPage() {
  const [mode, setMode] = useState<'simulation' | 'approval' | 'autonomous'>('approval')
  const [rateLimit, setRateLimit] = useState(2)
  const [stepTimeout, setStepTimeout] = useState(60)

  const handleSave = () => {
    // Save to orchestrator
    fetch(`${process.env.NEXT_PUBLIC_ORCHESTRATOR_URL}/settings`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ mode, rate_limit: rateLimit, step_timeout: stepTimeout }),
    }).then(() => alert('Settings saved!'))
  }

  return (
    <div className="px-4 sm:px-0">
      <div className="mb-8">
        <h1 className="text-2xl font-semibold text-gray-900">Settings</h1>
        <p className="mt-2 text-sm text-gray-700">
          Configure agent behavior and safety settings
        </p>
      </div>

      <div className="bg-white shadow sm:rounded-lg">
        <div className="px-4 py-5 sm:p-6">
          <div className="space-y-6">
            {/* Execution Mode */}
            <div>
              <label className="text-base font-semibold text-gray-900">Execution Mode</label>
              <p className="text-sm text-gray-500">Choose how the agent executes actions</p>
              <fieldset className="mt-4">
                <legend className="sr-only">Execution mode</legend>
                <div className="space-y-4">
                  <div className="flex items-center">
                    <input
                      id="simulation"
                      name="mode"
                      type="radio"
                      checked={mode === 'simulation'}
                      onChange={() => setMode('simulation')}
                      className="h-4 w-4 border-gray-300 text-primary-600 focus:ring-primary-600"
                    />
                    <label htmlFor="simulation" className="ml-3">
                      <span className="block text-sm font-medium text-gray-900">
                        Simulation Mode
                      </span>
                      <span className="block text-sm text-gray-500">
                        Plans actions but doesn't execute them (safest)
                      </span>
                    </label>
                  </div>
                  <div className="flex items-center">
                    <input
                      id="approval"
                      name="mode"
                      type="radio"
                      checked={mode === 'approval'}
                      onChange={() => setMode('approval')}
                      className="h-4 w-4 border-gray-300 text-primary-600 focus:ring-primary-600"
                    />
                    <label htmlFor="approval" className="ml-3">
                      <span className="block text-sm font-medium text-gray-900">
                        Approval Mode
                      </span>
                      <span className="block text-sm text-gray-500">
                        Requires approval before executing each action
                      </span>
                    </label>
                  </div>
                  <div className="flex items-center">
                    <input
                      id="autonomous"
                      name="mode"
                      type="radio"
                      checked={mode === 'autonomous'}
                      onChange={() => setMode('autonomous')}
                      className="h-4 w-4 border-gray-300 text-primary-600 focus:ring-primary-600"
                    />
                    <label htmlFor="autonomous" className="ml-3">
                      <span className="block text-sm font-medium text-gray-900">
                        Autonomous Mode
                      </span>
                      <span className="block text-sm text-gray-500">
                        Executes all actions automatically (use with caution)
                      </span>
                    </label>
                  </div>
                </div>
              </fieldset>
            </div>

            {/* Rate Limit */}
            <div>
              <label htmlFor="rate-limit" className="block text-sm font-medium text-gray-900">
                Rate Limit (actions per second)
              </label>
              <div className="mt-2">
                <input
                  type="number"
                  id="rate-limit"
                  min="1"
                  max="5"
                  value={rateLimit}
                  onChange={(e) => setRateLimit(Number(e.target.value))}
                  className="block w-full rounded-md border-gray-300 shadow-sm focus:border-primary-500 focus:ring-primary-500 sm:text-sm"
                />
              </div>
              <p className="mt-2 text-sm text-gray-500">
                Recommended: 1-3 actions/second
              </p>
            </div>

            {/* Step Timeout */}
            <div>
              <label htmlFor="step-timeout" className="block text-sm font-medium text-gray-900">
                Step Timeout (seconds)
              </label>
              <div className="mt-2">
                <input
                  type="number"
                  id="step-timeout"
                  min="10"
                  max="300"
                  value={stepTimeout}
                  onChange={(e) => setStepTimeout(Number(e.target.value))}
                  className="block w-full rounded-md border-gray-300 shadow-sm focus:border-primary-500 focus:ring-primary-500 sm:text-sm"
                />
              </div>
              <p className="mt-2 text-sm text-gray-500">
                Maximum time to wait for a step to complete
              </p>
            </div>
          </div>

          <div className="mt-6 flex justify-end">
            <button
              onClick={handleSave}
              className="rounded-md bg-primary-600 px-3 py-2 text-sm font-semibold text-white shadow-sm hover:bg-primary-500"
            >
              Save Settings
            </button>
          </div>
        </div>
      </div>

      {/* Safety Warning */}
      <div className="mt-6 rounded-md bg-yellow-50 p-4">
        <div className="flex">
          <div className="flex-shrink-0">
            <svg
              className="h-5 w-5 text-yellow-400"
              viewBox="0 0 20 20"
              fill="currentColor"
            >
              <path
                fillRule="evenodd"
                d="M8.485 2.495c.673-1.167 2.357-1.167 3.03 0l6.28 10.875c.673 1.167-.17 2.625-1.516 2.625H3.72c-1.347 0-2.189-1.458-1.515-2.625L8.485 2.495zM10 5a.75.75 0 01.75.75v3.5a.75.75 0 01-1.5 0v-3.5A.75.75 0 0110 5zm0 9a1 1 0 100-2 1 1 0 000 2z"
                clipRule="evenodd"
              />
            </svg>
          </div>
          <div className="ml-3">
            <h3 className="text-sm font-medium text-yellow-800">Safety Reminder</h3>
            <div className="mt-2 text-sm text-yellow-700">
              <p>
                Always run the terminal worker inside a VM or sandbox environment.
                Never run it directly on your host machine in autonomous mode.
              </p>
            </div>
          </div>
        </div>
      </div>
    </div>
  )
}
