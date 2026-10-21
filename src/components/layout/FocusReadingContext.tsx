"use client";

import React, { createContext, useContext, useState } from "react";

interface FocusReadingContextType {
  isFocusMode: boolean;
  toggleFocusMode: () => void;
  setFocusMode: (val: boolean) => void;
}

const FocusReadingContext = createContext<FocusReadingContextType>({
  isFocusMode: false,
  toggleFocusMode: () => {},
  setFocusMode: () => {},
});

export function FocusReadingProvider({ children }: { children: React.ReactNode }) {
  const [isFocusMode, setIsFocusMode] = useState(false);

  const toggleFocusMode = () => setIsFocusMode((prev) => !prev);
  const setFocusMode = (val: boolean) => setIsFocusMode(val);

  return (
    <FocusReadingContext.Provider value={{ isFocusMode, toggleFocusMode, setFocusMode }}>
      {children}
    </FocusReadingContext.Provider>
  );
}

export function useFocusReading() {
  return useContext(FocusReadingContext);
}
