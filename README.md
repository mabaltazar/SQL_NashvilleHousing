# 🧹 Nashville Housing Data Cleaning Project  
This project showcases a comprehensive data cleaning process using Microsoft SQL Server on housing sales data from Nashville. The dataset originally contained inconsistent, null, and duplicate values that were corrected and standardized using structured SQL techniques

🎯 Objective
To clean and prepare a housing dataset for analysis by:
- Standardizing and formatting date fields
- Handling null and inconsistent address values
- Separating multi-value fields into distinct components
- Removing duplicate records and unnecessary columns
  
🧰 Tools Used
- Microsoft SQL Server
- SQL Features:
- CONVERT()
- ISNULL()
- SUBSTRING(), CHARINDEX(), PARSENAME(), REPLACE()
- CASE statements
- ROW_NUMBER() and Common Table Expressions (CTEs)

🪜 Steps Taken
1. 📅 Date Standardization
- Converted the SaleDate field to a DATE format
- Added a new column SaleDateConverted due to type limitations
2. 🏡 Address Cleanup
- Populated NULL values in PropertyAddress using self-joins on matching ParcelIDs
- Split PropertyAddress into Street and City using SUBSTRING() + CHARINDEX()
3. 👤 Owner Address Parsing
- Used PARSENAME() + REPLACE() to split OwnerAddress into:
- OwnerAddressSplit, OwnerCitySplit, and OwnerStateSplit
4. 🧾 SoldAsVacant Standardization
- Transformed values:
- 'Y' → 'Yes'
- 'N' → 'No'
5. 🔁 Duplicate Removal
- Applied a ROW_NUMBER() CTE to identify duplicate entries
- (Commented DELETE statement for safety inspection before removal)
6. 🗑️ Column Pruning
- Dropped redundant columns: OwnerAddress, PropertyAddress, SaleDate

📂 Dataset
- Dataset: [Nashville Housing Data](https://www.kaggle.com/datasets/tmthyjames/nashville-housing-data)
- Housing sales data fields:
- ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference, OwnerAddress, SoldAsVacant
