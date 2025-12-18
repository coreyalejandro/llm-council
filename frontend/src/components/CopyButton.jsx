import { useState } from 'react';
import './CopyButton.css';

export default function CopyButton({ text, label = 'Copy', copiedLabel = 'Copied' }) {
  const [status, setStatus] = useState('idle'); // idle | copied | error

  const handleCopy = async () => {
    try {
      if (typeof text !== 'string' || text.length === 0) {
        setStatus('error');
        setTimeout(() => setStatus('idle'), 1500);
        return;
      }

      await navigator.clipboard.writeText(text);
      setStatus('copied');
      setTimeout(() => setStatus('idle'), 1200);
    } catch {
      // Fallback: older browsers / permissions
      try {
        const textarea = document.createElement('textarea');
        textarea.value = text;
        textarea.setAttribute('readonly', '');
        textarea.style.position = 'absolute';
        textarea.style.left = '-9999px';
        document.body.appendChild(textarea);
        textarea.select();
        document.execCommand('copy');
        document.body.removeChild(textarea);
        setStatus('copied');
        setTimeout(() => setStatus('idle'), 1200);
      } catch {
        setStatus('error');
        setTimeout(() => setStatus('idle'), 1500);
      }
    }
  };

  const buttonText =
    status === 'copied' ? copiedLabel : status === 'error' ? 'Copy failed' : label;

  return (
    <button type="button" className="copy-btn" onClick={handleCopy}>
      {buttonText}
    </button>
  );
}

