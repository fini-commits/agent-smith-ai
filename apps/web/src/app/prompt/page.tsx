'use client'

import { useState } from 'react'

export default function PromptPage() {
  const [goal, setGoal] = useState('')
  const [running, setRunning] = useState(false)
  const [result, setResult] = useState<any>(null)
  const orchestratorUrl = process.env.NEXT_PUBLIC_ORCHESTRATOR_URL || 'http://localhost:8010'
  const workerUrl = process.env.NEXT_PUBLIC_WORKER_URL || 'http://localhost:8002'

  async function submitGoal() {
    setRunning(true)
    setResult(null)
    try {
      const resp = await fetch(`${orchestratorUrl}/run`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ text: goal }),
      })
      const data = await resp.json()
      setResult(data)
    } catch (e) {
      setResult({ error: String(e) })
    } finally {
      setRunning(false)
    }
  }

  async function toggleRealActions(enabled: boolean) {
    try {
      await fetch(`${workerUrl}/set_actions_enabled`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ enabled }),
      })
      alert(`Set actions_enabled=${enabled}`)
    } catch (e) {
      alert('Failed to toggle actions: ' + e)
    }
  }

  return (
    <div className="p-6">
      <h1 className="text-2xl font-bold mb-4">Prompt the AI</h1>
      <textarea
        value={goal}
        onChange={(e) => setGoal(e.target.value)}
        placeholder="Describe what you want the AI to do (e.g. Open Calculator)"
        className="w-full border rounded p-2 mb-3 h-28"
      />
      <div className="flex gap-2 mb-4">
        <button
          className="px-3 py-2 bg-primary-600 text-white rounded"
          onClick={submitGoal}
          disabled={running || !goal}
        >
          {running ? 'Sending...' : 'Send Goal'}
        </button>
        <button className="px-3 py-2 bg-gray-200 rounded" onClick={() => setGoal('')}>
          Clear
        </button>
      </div>

      <div className="mb-6">
        <strong>Dangerous (for demos only):</strong>
        <div className="mt-2 flex gap-2">
          <button
            className="px-3 py-2 bg-red-600 text-white rounded"
            onClick={() => toggleRealActions(true)}
          >
            Enable Real Actions
          </button>
          <button
            className="px-3 py-2 bg-green-600 text-white rounded"
            onClick={() => toggleRealActions(false)}
          >
            Disable Real Actions
          </button>
        </div>
      </div>

      <div>
        <h2 className="text-xl font-semibold">Result</h2>
        <pre className="mt-2 bg-gray-100 p-3 rounded">{JSON.stringify(result, null, 2)}</pre>
      </div>
    </div>
  )
}
