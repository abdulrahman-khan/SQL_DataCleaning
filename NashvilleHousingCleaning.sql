use [Portfolio-Cleaning2]
SELECT * FROM NashvilleHousing;


-- Standardize SaleDate to type DATE
ALTER TABLE NashvilleHousing ALTER COLUMN SaleDate DATE
UPDATE NashvilleHousing
SET SaleDate = CONVERT(Date, SaleDate)

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



-- Splitting Owner Address into individual columns
SELECT owneraddress FROM NashvilleHousing

--parsename() is a weird but interesting function
SELECT 
	PARSENAME(REPLACE(OwnerAddress, ',', '.') ,3),
	PARSENAME(REPLACE(OwnerAddress, ',', '.') ,2),
	PARSENAME(REPLACE(OwnerAddress, ',', '.') ,1)
FROM NashvilleHousing;

ALTER TABLE NashvilleHousing
ADD OwnerSplitAddress NVARCHAR(255);

ALTER TABLE NashvilleHousing
ADD OwnerSplitCity NVARCHAR(255);

ALTER TABLE NashvilleHousing
ADD OwnerSplitState NVARCHAR(255);

UPDATE NashvilleHousing
SET 
	OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') ,3),
	OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2),
	OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') ,1)

SELECT OwnerAddress, OwnerSplitAddress, OwnerSplitCity, OwnerSplitState
FROM NashvilleHousing


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



-- Removing Useless Columns - OwnerAddress, PropertyAddress, SaleDate
-- OwnerAddress and PropertyAddress have been split into seperate columns, originals are useless
-- SaleDate was converted to a DATE data type in a new column, original is useless
-- 
ALTER TABLE NashvilleHousing
DROP COLUMN OwnerAddress, PropertyAddress, SaleDate


SELECT * FROM NashvilleHousing

order by OwnerName desc
;

