import type { InputHTMLAttributes } from "react";
import clsx from "clsx";

interface TextFieldProps extends InputHTMLAttributes<HTMLInputElement> {
  label: string;
  error?: string;
}

export function TextField({
  label,
  error,
  id,
  className,
  ...props
}: TextFieldProps) {
  const fieldId = id ?? label.toLowerCase().replace(/\s+/g, "-");
  return (
    <div className="flex flex-col gap-1.5 text-left">
      <label htmlFor={fieldId} className="text-sm font-semibold text-sampaguita/80">
        {label}
      </label>
      <input
        id={fieldId}
        className={clsx(
          "w-full rounded-2xl border-2 bg-ink px-4 py-3 text-lg font-display tracking-wide text-sampaguita placeholder:text-sampaguita/30 outline-none transition-colors",
          error ? "border-sunset" : "border-ink-3 focus:border-mango",
          className
        )}
        aria-invalid={!!error}
        aria-describedby={error ? `${fieldId}-error` : undefined}
        {...props}
      />
      {error && (
        <p id={`${fieldId}-error`} className="text-sm text-sunset" role="alert">
          {error}
        </p>
      )}
    </div>
  );
}
