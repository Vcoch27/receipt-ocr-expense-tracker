import assert from 'node:assert/strict';
import { request } from 'node:http';
import { once } from 'node:events';
import test from 'node:test';

process.env.GEMINI_API_KEY = 'test-only-key';
process.env.PORT = '0';
let upstreamCalls = 0;
globalThis.fetch = async (url, options) => {
  upstreamCalls++;
  assert.match(url, /models\/gemini-3\.1-flash-lite:generateContent$/);
  assert.equal(options.headers['x-goog-api-key'], 'test-only-key');
  return {
    ok: true,
    json: async () => ({
      candidates: [{ content: { parts: [{ text: JSON.stringify({
        merchant: 'Test Shop', amount: 150000, date: '2026-10-09',
        note: null, transactionReference: null,
      }) }] } }],
    }),
  };
};
const { server } = await import('./server.mjs');
if (!server.listening) await once(server, 'listening');

function post(payload) {
  return new Promise((resolve, reject) => {
    const body = JSON.stringify(payload);
    const req = request({
      hostname: '127.0.0.1', port: server.address().port,
      path: '/analyze', method: 'POST',
      headers: { 'content-type': 'application/json', 'content-length': Buffer.byteLength(body) },
    }, res => {
      const chunks = [];
      res.on('data', chunk => chunks.push(chunk));
      res.on('end', () => resolve({ status: res.statusCode, body: JSON.parse(Buffer.concat(chunks)) }));
    });
    req.on('error', reject);
    req.end(body);
  });
}

test('rejects malformed input without calling Gemini', async () => {
  const result = await post({ source: 'receipt', imageBase64: 'bad', mimeType: 'image/jpeg', rawText: '' });
  assert.equal(result.status, 400);
  assert.equal(upstreamCalls, 0);
});

test('forwards a valid image and returns validated fields', async () => {
  const result = await post({
    source: 'receipt',
    imageBase64: 'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mP8/x8AAusB9YcQ3QAAAABJRU5ErkJggg==',
    mimeType: 'image/png', rawText: 'Test Shop',
  });
  assert.equal(result.status, 200);
  assert.equal(result.body.amount, 150000);
  assert.equal(result.body.merchant, 'Test Shop');
  assert.equal(upstreamCalls, 1);
});

test.after(() => server.close());
