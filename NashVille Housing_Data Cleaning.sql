-- Data Cleaning

-- Let's check our data
SELECT *
FROM DataCleaningProject.dbo.NashvilleDataCleaning

-- 1. Standardize the date

-- Converting the SaleDate column to a date format
SELECT SaleDate, CONVERT(date, SaleDate)
FROM DataCleaningProject.dbo.NashvilleDataCleaning

UPDATE DataCleaningProject.dbo.NashvilleDataCleaning
SET SaleDate = CONVERT(date, SaleDate)

-- Updating the current SaleDate column did not work. Adding a new column instead and convert the date
ALTER TABLE DataCleaningProject.dbo.NashvilleDataCleaning
ADD SaleDateConverted date;

UPDATE DataCleaningProject.dbo.NashvilleDataCleaning
SET SaleDateConverted = CONVERT(date, SaleDate)


-- 2. Populate the NULL values of PropertyAddress column
SELECT PropertyAddress
FROM DataCleaningProject.dbo.NashvilleDataCleaning
WHERE PropertyAddress IS NULL

-- Checking the NULL values
SELECT *
FROM DataCleaningProject.dbo.NashvilleDataCleaning
--WHERE ParcelID = '026 05 0 017.00'
ORDER BY PropertyAddress

-- Checking on the null values in PropertyAddress, there are addresses with the same ParcelID that has address
-- We can populate the null values by referencing the same ParcelID that has address populated

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM DataCleaningProject.dbo.NashvilleDataCleaning a
JOIN DataCleaningProject.dbo.NashvilleDataCleaning b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL

-- Populate the NULL values
UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM DataCleaningProject.dbo.NashvilleDataCleaning a
JOIN DataCleaningProject.dbo.NashvilleDataCleaning b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL


-- 3. Separate the PropertyAddress into individual columns like Street and City 

-- Breaking out the PropertyAddress
SELECT SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1) AS Street
	,SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress)) AS City
	--,CHARINDEX(',', PropertyAddress)
FROM DataCleaningProject.dbo.NashvilleDataCleaning

-- Adding new columns for the separated PropertyAddress
ALTER TABLE DataCleaningProject.dbo.NashvilleDataCleaning
ADD PropertyAddressSplit Nvarchar(255);

ALTER TABLE DataCleaningProject.dbo.NashvilleDataCleaning
ADD PropertyCitySplit Nvarchar(255);

-- Inserting the data into the new columns
UPDATE DataCleaningProject.dbo.NashvilleDataCleaning
SET PropertyAddressSplit = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1)

UPDATE DataCleaningProject.dbo.NashvilleDataCleaning
SET PropertyCitySplit = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress))


-- 4. Checking if we can populate the NULL values in OwnerAddress
SELECT *
FROM DataCleaningProject.dbo.NashvilleDataCleaning
--WHERE ParcelID = '011 15 0A 004.00'
WHERE OwnerAddress IS NULL

-- 5. It seems we cannot populate the NULL values in the OwnerAddress, however, we can also separate the Address individually into Street, City, and State
SELECT
PARSENAME(REPLACE(OwnerAddress,',','.'), 3),
PARSENAME(REPLACE(OwnerAddress,',','.'), 2),
PARSENAME(REPLACE(OwnerAddress,',','.'), 1)
FROM DataCleaningProject.dbo.NashvilleDataCleaning

-- Adding new columns for separated OwnerAddress
ALTER TABLE DataCleaningProject.dbo.NashvilleDataCleaning
ADD OwnerAddressSplit Nvarchar(255);

ALTER TABLE DataCleaningProject.dbo.NashvilleDataCleaning
ADD OwnerCitySplit Nvarchar(255);

ALTER TABLE DataCleaningProject.dbo.NashvilleDataCleaning
ADD OwnerStateSplit Nvarchar(255);

-- Inserting data into the new columns
UPDATE DataCleaningProject.dbo.NashvilleDataCleaning
SET OwnerAddressSplit = PARSENAME(REPLACE(OwnerAddress,',','.'), 3)

UPDATE DataCleaningProject.dbo.NashvilleDataCleaning
SET OwnerCitySplit = PARSENAME(REPLACE(OwnerAddress,',','.'), 2)

UPDATE DataCleaningProject.dbo.NashvilleDataCleaning
SET OwnerStateSplit = PARSENAME(REPLACE(OwnerAddress,',','.'), 1)


-- 6. Change Y and N to Yes and No in SoldAsVacant column
SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM DataCleaningProject.dbo.NashvilleDataCleaning
GROUP BY SoldAsVacant
ORDER BY 2

-- Changing Y to Yes and N to No
SELECT SoldAsVacant,
CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	 WHEN SoldAsVacant = 'N' THEN 'No'
	 ELSE SoldAsVacant
	 END 
FROM DataCleaningProject.dbo.NashvilleDataCleaning

-- Updating the SoldAsVacant column
UPDATE DataCleaningProject.dbo.NashvilleDataCleaning
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
						WHEN SoldAsVacant = 'N' THEN 'No'
						ELSE SoldAsVacant
						END

-- 7. Remove the duplicate records

WITH DUP_CTE AS
(
	SELECT *, 
	ROW_NUMBER() OVER ( PARTITION BY ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference 
				 ORDER BY UniqueID) duplicates
	From DataCleaningProject.dbo.NashvilleDataCleaning
)
SELECT *
-- DELETE
FROM DUP_CTE
WHERE duplicates > 1


-- 8. Removing unecessary columns

SELECT * 
FROM DataCleaningProject.dbo.NashvilleDataCleaning

ALTER TABLE DataCleaningProject.dbo.NashvilleDataCleaning
DROP COLUMN OwnerAddress, PropertyAddress, SaleDate

