'use client'

import useSWR from 'swr'
import { formatDistanceToNow } from 'date-fns'

const fetcher = (url: string) => fetch(url).then((res) => res.json())

interface Run {
  id: string
  goal: string
  status: 'pending' | 'running' | 'completed' | 'failed' | 'paused'
  created_at: string
  updated_at: string
  current_step?: number
  total_steps?: number
}

export default function Home() {
  const { data, error, isLoading } = useSWR<{ runs: Run[] }>(
    `${process.env.NEXT_PUBLIC_ORCHESTRATOR_URL}/runs`,
    fetcher,
    { refreshInterval: 2000 }
  )

  if (error) return <div className="text-red-600">Failed to load runs</div>
  if (isLoading) return <div>Loading...</div>

  const runs = data?.runs || []

  return (
    <div className="px-4 sm:px-0">
      <div className="sm:flex sm:items-center">
        <div className="sm:flex-auto">
          <h1 className="text-2xl font-semibold text-gray-900">Runs</h1>
          <p className="mt-2 text-sm text-gray-700">
            A list of all AI agent execution runs with their current status
          </p>
        </div>
        <div className="mt-4 sm:mt-0 sm:ml-16 sm:flex-none">
          <button
            type="button"
            className="block rounded-md bg-primary-600 px-3 py-2 text-center text-sm font-semibold text-white shadow-sm hover:bg-primary-500"
            onClick={() => {
              const goal = prompt('Enter goal:')
              if (goal) {
                fetch(`${process.env.NEXT_PUBLIC_ORCHESTRATOR_URL}/run`, {
                  method: 'POST',
                  headers: { 'Content-Type': 'application/json' },
                  body: JSON.stringify({ text: goal }),
                }).then(() => window.location.reload())
              }
            }}
          >
            New Run
          </button>
        </div>
      </div>

      <div className="mt-8 flow-root">
        <div className="-mx-4 -my-2 overflow-x-auto sm:-mx-6 lg:-mx-8">
          <div className="inline-block min-w-full py-2 align-middle sm:px-6 lg:px-8">
            <div className="overflow-hidden shadow ring-1 ring-black ring-opacity-5 sm:rounded-lg">
              <table className="min-w-full divide-y divide-gray-300">
                <thead className="bg-gray-50">
                  <tr>
                    <th className="py-3.5 pl-4 pr-3 text-left text-sm font-semibold text-gray-900 sm:pl-6">
                      Goal
                    </th>
                    <th className="px-3 py-3.5 text-left text-sm font-semibold text-gray-900">
                      Status
                    </th>
                    <th className="px-3 py-3.5 text-left text-sm font-semibold text-gray-900">
                      Progress
                    </th>
                    <th className="px-3 py-3.5 text-left text-sm font-semibold text-gray-900">
                      Created
                    </th>
                    <th className="relative py-3.5 pl-3 pr-4 sm:pr-6">
                      <span className="sr-only">View</span>
                    </th>
                  </tr>
                </thead>
                <tbody className="divide-y divide-gray-200 bg-white">
                  {runs.length === 0 ? (
                    <tr>
                      <td colSpan={5} className="px-3 py-8 text-center text-sm text-gray-500">
                        No runs yet. Click "New Run" to get started.
                      </td>
                    </tr>
                  ) : (
                    runs.map((run) => (
                      <tr key={run.id}>
                        <td className="whitespace-nowrap py-4 pl-4 pr-3 text-sm font-medium text-gray-900 sm:pl-6">
                          {run.goal}
                        </td>
                        <td className="whitespace-nowrap px-3 py-4 text-sm">
                          <span
                            className={`inline-flex rounded-full px-2 text-xs font-semibold leading-5 ${
                              run.status === 'completed'
                                ? 'bg-green-100 text-green-800'
                                : run.status === 'running'
                                ? 'bg-blue-100 text-blue-800'
                                : run.status === 'failed'
                                ? 'bg-red-100 text-red-800'
                                : run.status === 'paused'
                                ? 'bg-yellow-100 text-yellow-800'
                                : 'bg-gray-100 text-gray-800'
                            }`}
                          >
                            {run.status}
                          </span>
                        </td>
                        <td className="whitespace-nowrap px-3 py-4 text-sm text-gray-500">
                          {run.current_step && run.total_steps
                            ? `${run.current_step}/${run.total_steps}`
                            : '—'}
                        </td>
                        <td className="whitespace-nowrap px-3 py-4 text-sm text-gray-500">
                          {formatDistanceToNow(new Date(run.created_at), { addSuffix: true })}
                        </td>
                        <td className="relative whitespace-nowrap py-4 pl-3 pr-4 text-right text-sm font-medium sm:pr-6">
                          <a
                            href={`/runs/${run.id}`}
                            className="text-primary-600 hover:text-primary-900"
                          >
                            View<span className="sr-only">, {run.goal}</span>
                          </a>
                        </td>
                      </tr>
                    ))
                  )}
                </tbody>
              </table>
            </div>
          </div>
        </div>
      </div>
    </div>
  )
}
