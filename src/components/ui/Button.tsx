import type { ButtonHTMLAttributes, ReactNode } from "react";
import clsx from "clsx";

type Variant = "primary" | "secondary" | "ghost" | "danger";
type Size = "md" | "lg";

interface ButtonProps extends ButtonHTMLAttributes<HTMLButtonElement> {
  variant?: Variant;
  size?: Size;
  children: ReactNode;
}

const variantClasses: Record<Variant, string> = {
  primary:
    "bg-mango text-ink hover:bg-mango-dim active:scale-[0.98] shadow-[0_6px_0_0_var(--color-mango-dim)] hover:shadow-[0_4px_0_0_var(--color-mango-dim)] active:shadow-[0_2px_0_0_var(--color-mango-dim)] active:translate-y-1",
  secondary:
    "bg-ube text-sampaguita hover:bg-ube-dim active:scale-[0.98] shadow-[0_6px_0_0_var(--color-ube-dim)] hover:shadow-[0_4px_0_0_var(--color-ube-dim)] active:shadow-[0_2px_0_0_var(--color-ube-dim)] active:translate-y-1",
  ghost:
    "bg-ink-2 text-sampaguita border-2 border-ink-3 hover:border-mango/60",
  danger:
    "bg-sunset/90 text-ink hover:bg-sunset active:scale-[0.98]",
};

const sizeClasses: Record<Size, string> = {
  md: "px-5 py-3 text-sm rounded-2xl",
  lg: "px-8 py-5 text-lg rounded-[1.25rem]",
};

export function Button({
  variant = "primary",
  size = "md",
  className,
  children,
  disabled,
  ...props
}: ButtonProps) {
  return (
    <button
      className={clsx(
        "font-display font-semibold transition-all duration-150 select-none touch-manipulation",
        "focus-visible:outline-3 focus-visible:outline-mango",
        "disabled:opacity-40 disabled:cursor-not-allowed disabled:shadow-none disabled:active:translate-y-0 disabled:active:scale-100",
        variantClasses[variant],
        sizeClasses[size],
        className
      )}
      disabled={disabled}
      {...props}
    >
      {children}
    </button>
  );
}
