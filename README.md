# Cleaning Nashville Housing Data for Analysis
<img width="50" height="50" src="https://github.com/user-attachments/assets/79bd5fdd-5772-4087-803a-338a21fd65fa">

## Overview of the Data
Nashville Housing Data consists of over 700k records. The data seems somewhat clean at a first glance, however there are a few improvments that can be done to better prepare the data for data analysis. This reposity will showcase some of the SQL queries ran to help prepare the data.

The sql queries fixes data types, splits the address into seperate columns, fills missing data and deletes duplicates. 

## Raw Data
![image](https://github.com/user-attachments/assets/e347c46b-604f-4294-9088-828f5ef09260)

```sql
-- Standardize SaleDate to type DATE
ALTER TABLE NashvilleHousing ALTER COLUMN SaleDate DATE
UPDATE NashvilleHousing
SET SaleDate = CONVERT(Date, SaleDate)
```

```sql
-- Populate Blank Property Address Data
-- if there is a duplicate parcel_id, the address data will be the same 
SELECT  *
FROM NashvilleHousing
WHERE PropertyAddress is NULL
ORDER BY ParcelID

SELECT a.ParcelID, a.PropertyAddress, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM NashvilleHousing a 
JOIN NashvilleHousing b on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] != b.[UniqueID ]
	AND a.PropertyAddress is null

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
	FROM NashvilleHousing a 
JOIN NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] != b.[UniqueID ]
	AND a.PropertyAddress is null;
```


```sql
-- Seperating Address into individual columns
SELECT PropertyAddress, PropertySplitAddress, PropertySplitCity FROM NashvilleHousing

SELECT 
	CHARINDEX(',', propertyaddress), 
	SUBSTRING(PropertyAddress, 1, CHARINDEX(',', pROPERtyAddress)-1 ) as Address,
	SUBSTRING(PropertyAddress, CHARINDEX(',', pROPERtyAddress)+2, Len(PropertyAddress)) as Address2
FROM NashvilleHousing;

-- Adding the two new columns to the Table
ALTER TABLE NashvilleHousing
Add PropertySplitAddress NVARCHAR(255)

ALTER TABLE NashvilleHousing
Add PropertySplitCity NVARCHAR(255)

UPDATE NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', pROPERtyAddress)-1 ),
PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', pROPERtyAddress)+2, Len(PropertyAddress))
```

```sql
-- Change Y/N values to a yes/no in SOLD AS VACANT colun
SELECT Distinct(SoldAsVacant), count(SoldAsVacant)
FROM NashvilleHousing
group by SoldAsVacant
order by 2

SELECT SoldAsVacant,
	CASE 
		WHEN SoldAsVacant = 'Y' THEN 'Yes'
		WHEN SoldAsVacant = 'N' THEN 'Yes'
		ELSE SoldAsVacant
	END
FROM NashvilleHousing

UPDATE NashvilleHousing
SET SoldAsVacant = 
	CASE 
		WHEN SoldAsVacant = 'Y' THEN 'Yes'
		WHEN SoldAsVacant = 'N' THEN 'Yes'
		ELSE SoldAsVacant
	END
```

```sql
-- Removing the Duplicates rows and Unused Columns
-- using a CTE and windows functions to find duplicate values
WITH RowNumCTE AS (
	SELECT *,
		ROW_NUMBER() OVER(
			PARTITION BY 
				ParcelID,
				PropertyAddress,
				SalePrice,
				SaleDate,
				LegalReference
			ORDER BY
				uniqueID
			) as roww
	FROM NashvilleHousing
)

DELETE FROM RowNumCTE WHERE roww > 1;
```


## Cleaned Data
![image](https://github.com/user-attachments/assets/162652e0-81da-4545-ad23-1e0c8855a0ed)



