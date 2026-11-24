// BINGO ET v3.0 - Web Portal & Payment Configuration
const BINGO_ET_CONFIG = {
  brandName: "BINGO ET",
  version: "v3.0",
  referencePortal: "http://www.bingo1020.com",
  apiBaseUrl: "https://bingo1020.onrender.com",
  defaultLanguage: "am",
  supportedLanguages: [
    { code: "am", label: "Amharic", nativeLabel: "አማርኛ", dir: "ltr" },
    { code: "om", label: "Afan Oromo", nativeLabel: "Afaan Oromoo", dir: "ltr" },
    { code: "ti", label: "Tigrigna", nativeLabel: "ትግርኛ", dir: "ltr" },
    { code: "en", label: "English", nativeLabel: "English", dir: "ltr" },
    { code: "ar", label: "Arabic", nativeLabel: "العربية", dir: "rtl" },
    { code: "other", label: "Others", nativeLabel: "Others", dir: "ltr" }
  ],
  accountHolder: "Kibur shiferaw kassa",
  roundIntervalSeconds: 120,
  selectableCardRange: { min: 1, max: 600 },
  paymentAccounts: [
    {
      id: "telebirr-1",
      method: "Telebirr",
      accountNumber: "0912341486",
      accountHolder: "Kibur shiferaw kassa",
      label: "Telebirr Primary"
    },
    {
      id: "telebirr-2",
      method: "Telebirr",
      accountNumber: "0941705946",
      accountHolder: "Kibur shiferaw kassa",
      label: "Telebirr Secondary"
    },
    {
      id: "cbe-1",
      method: "CBE",
      accountNumber: "1000058081624",
      accountHolder: "Kibur shiferaw kassa",
      label: "Commercial Bank of Ethiopia (CBE)"
    },
    {
      id: "boa-1",
      method: "BOA",
      accountNumber: "82323805",
      accountHolder: "Kibur shiferaw kassa",
      label: "Bank of Abyssinia (BOA)"
    }
  ],
  endpoints: {
    loginV3: "/api/user/login/v3",
    resetVerify: "/api/user/reset/verify",
    resetComplete: "/api/user/reset/complete",
    activeBanner: "/api/banner/active",
    withdrawMethods: "/api/withdraw-method/available",
    withdrawV2: "/api/transaction/withdraw/v2"
  }
};
