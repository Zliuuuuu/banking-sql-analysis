# ========================================
# Figure 1: Monthly Deposit and Withdrawal Trends
# ========================================

# 1. Load data
loan_portfolio <- read.csv("data/loan_portfolio.csv")

# 2. Load package
library(ggplot2)

# 3. Select deposit and withdrawal transactions
monthly_plot <- subset(
  monthly_transactions,
  type == "deposit" | type == "withdrawal"
)

# 4. Convert month to Date format
monthly_plot$month <- as.Date(monthly_plot$month)

# 5. Create line chart
ggplot(
  monthly_plot,
  aes(x = month, y = total_amount, color = type)
) +
  geom_line(linewidth = 1) +
  labs(
    title = "Monthly Deposit and Withdrawal Trends",
    x = "Month",
    y = "Total Transaction Amount",
    color = "Transaction Type"
  ) +
  theme_minimal()

# 6. Save figure
ggsave(
  filename = "figures/monthly_transaction_trends.png",
  plot = p1,
  width = 10,
  height = 6,
  dpi = 300
)


# ========================================
# Figure 2: Loan Portfolio by Status
# ========================================


# 1. Load loan data
monthly_transactions <- read.csv("data/monthly_transactions.csv")

# 2. Create bar chart
ggplot(
  loan_portfolio,
  aes(x = status, y = total_loan_amount, fill = status)
) +
  geom_col() +
  scale_y_continuous(
    labels = function(x) paste0(round(x / 1000000, 1), "M")
  ) +
  labs(
    title = "Loan Portfolio by Status",
    x = "Loan Status",
    y = "Total Loan Amount (Millions)",
    fill = "Loan Status"
  ) +
  theme_minimal()

# 3. Save figure
ggsave(
  "figures/loan_portfolio_by_status.png",
  width = 10,
  height = 6,
  dpi = 300
)

# ========================================
# Figure 3: Branch Loan Default Rates
# ========================================

# 1. Load data
branch_default_rates <- read.csv("data/branch_default_rates.csv")

# 2. Create horizontal bar chart
ggplot(
  branch_default_rates,
  aes(
    x = reorder(branch_name, default_rate_pct),
    y = default_rate_pct
  )
) +
  geom_col(fill = "steelblue") +
  coord_flip() +
  labs(
    title = "Loan Default Rates by Branch",
    x = "Branch",
    y = "Default Rate (%)"
  ) +
  theme_minimal()

# 3. Save figure
ggsave(
  filename = "figures/branch_default_rates.png",
  plot = p3,
  width = 10,
  height = 6,
  dpi = 300
)