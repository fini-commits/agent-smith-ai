'use client'

import useSWR from 'swr'
import { formatDistanceToNow } from 'date-fns'
import { use } from 'react'

const fetcher = (url: string) => fetch(url).then((res) => res.json())

interface Step {
  id: string
  run_id: string
  step_number: number
  action_type: string
  action_data: any
  screenshot_before?: string
  screenshot_after?: string
  status: 'pending' | 'running' | 'completed' | 'failed'
  created_at: string
  reasoning?: string
}

interface RunDetail {
  id: string
  goal: string
  status: string
  created_at: string
  steps: Step[]
}

export default function RunDetailPage({ params }: { params: Promise<{ id: string }> }) {
  const { id } = use(params)
  const { data, error, isLoading, mutate } = useSWR<RunDetail>(
    `${process.env.NEXT_PUBLIC_ORCHESTRATOR_URL}/runs/${id}`,
    fetcher,
    { refreshInterval: 1000 }
  )

  const handleApprove = async (stepId: string) => {
    await fetch(`${process.env.NEXT_PUBLIC_ORCHESTRATOR_URL}/runs/${id}/approve`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ step_id: stepId }),
    })
    mutate()
  }

  const handleReject = async (stepId: string) => {
    await fetch(`${process.env.NEXT_PUBLIC_ORCHESTRATOR_URL}/runs/${id}/reject`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ step_id: stepId }),
    })
    mutate()
  }

  if (error) return <div className="text-red-600">Failed to load run</div>
  if (isLoading) return <div>Loading...</div>
  if (!data) return <div>Run not found</div>

  return (
    <div className="px-4 sm:px-0">
      <div className="mb-8">
        <h1 className="text-2xl font-semibold text-gray-900">{data.goal}</h1>
        <div className="mt-2 flex items-center space-x-4 text-sm text-gray-500">
          <span
            className={`inline-flex rounded-full px-2 py-1 text-xs font-semibold ${
              data.status === 'completed'
                ? 'bg-green-100 text-green-800'
                : data.status === 'running'
                ? 'bg-blue-100 text-blue-800'
                : data.status === 'failed'
                ? 'bg-red-100 text-red-800'
                : 'bg-gray-100 text-gray-800'
            }`}
          >
            {data.status}
          </span>
          <span>{formatDistanceToNow(new Date(data.created_at), { addSuffix: true })}</span>
        </div>
      </div>

      <div className="space-y-8">
        <h2 className="text-lg font-medium text-gray-900">Steps Timeline</h2>
        {data.steps.map((step, idx) => (
          <div
            key={step.id}
            className="bg-white rounded-lg shadow border border-gray-200 overflow-hidden"
          >
            <div className="px-6 py-4 bg-gray-50 border-b border-gray-200">
              <div className="flex items-center justify-between">
                <div className="flex items-center space-x-3">
                  <span className="flex-shrink-0 w-8 h-8 flex items-center justify-center rounded-full bg-primary-100 text-primary-700 font-semibold">
                    {step.step_number}
                  </span>
                  <div>
                    <h3 className="text-sm font-medium text-gray-900">
                      {step.action_type}
                    </h3>
                    <p className="text-xs text-gray-500">
                      {formatDistanceToNow(new Date(step.created_at), { addSuffix: true })}
                    </p>
                  </div>
                </div>
                <span
                  className={`inline-flex rounded-full px-2 py-1 text-xs font-semibold ${
                    step.status === 'completed'
                      ? 'bg-green-100 text-green-800'
                      : step.status === 'running'
                      ? 'bg-blue-100 text-blue-800'
                      : step.status === 'failed'
                      ? 'bg-red-100 text-red-800'
                      : 'bg-gray-100 text-gray-800'
                  }`}
                >
                  {step.status}
                </span>
              </div>
            </div>

            <div className="px-6 py-4">
              {step.reasoning && (
                <div className="mb-4">
                  <h4 className="text-sm font-medium text-gray-700 mb-1">Reasoning</h4>
                  <p className="text-sm text-gray-600">{step.reasoning}</p>
                </div>
              )}

              <div className="mb-4">
                <h4 className="text-sm font-medium text-gray-700 mb-1">Action</h4>
                <pre className="text-xs bg-gray-50 p-3 rounded overflow-x-auto">
                  {JSON.stringify(step.action_data, null, 2)}
                </pre>
              </div>

              <div className="grid grid-cols-2 gap-4">
                {step.screenshot_before && (
                  <div>
                    <h4 className="text-sm font-medium text-gray-700 mb-2">Before</h4>
                    <img
                      src={`data:image/png;base64,${step.screenshot_before}`}
                      alt="Before"
                      className="border border-gray-300 rounded"
                    />
                  </div>
                )}
                {step.screenshot_after && (
                  <div>
                    <h4 className="text-sm font-medium text-gray-700 mb-2">After</h4>
                    <img
                      src={`data:image/png;base64,${step.screenshot_after}`}
                      alt="After"
                      className="border border-gray-300 rounded"
                    />
                  </div>
                )}
              </div>

              {step.status === 'pending' && (
                <div className="mt-4 flex space-x-3">
                  <button
                    onClick={() => handleApprove(step.id)}
                    className="flex-1 bg-green-600 text-white px-4 py-2 rounded-md text-sm font-medium hover:bg-green-700"
                  >
                    ✓ Approve
                  </button>
                  <button
                    onClick={() => handleReject(step.id)}
                    className="flex-1 bg-red-600 text-white px-4 py-2 rounded-md text-sm font-medium hover:bg-red-700"
                  >
                    ✗ Reject
                  </button>
                </div>
              )}
            </div>
          </div>
        ))}

        {data.steps.length === 0 && (
          <div className="text-center py-8 text-gray-500">
            No steps yet
          </div>
        )}
      </div>
    </div>
  )
}
