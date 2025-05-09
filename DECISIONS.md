# Design Choices and Justifications – Global Developer Salary DBT Project

## 1. Why Modified Z-Score?

Modified Z-score is chosen over the traditional Z-score for robust outlier detection. It uses the **median** and **MAD (median absolute deviation)** instead of the mean and standard deviation. This is justified because:

* **Salary distributions are typically skewed** (often lognormal), so using the mean and standard deviation (as in traditional Z-score) can be misleading.
* **MAD is more robust to extreme values** than standard deviation, avoiding circular reasoning when detecting outliers.
* Modified Z-score better handles **small groups** and **unbalanced categories**, which are common in survey data.

Outlier detection is critical to avoid skewed aggregate results, and it is applied to the `salary_norm` column (after normalization).

---

## 2. Why Normalize Salaries?

### 2.1. Normalization by Inflation (to 2024)

* Ensures **temporal comparability** across survey years.
* A **global inflation factor** is applied for simplicity and consistency.
* Limitation: ignores region-specific inflation or wage shifts, such as the post-COVID tech boom and bust.

### 2.2. Normalization by GDP-PPP

* Allows for **cross-country comparison** by accounting for local economic strength.
* Assumes that software developers are subject to local economic factors and purchasing power parity.
* Limitation: presumes equivalency in developer roles and societal value across countries.

### 2.3. Combined Normalization (`salary_norm`)

* First by inflation, then by GDP-PPP.
* This supports fair, **globally contextual salary comparison**.

---

## Justified Omissions

* **DBT versioned models** omitted due to small scope. Git handles version control.
* **DBT Cloud access controls** omitted; lies outside current project scope.
