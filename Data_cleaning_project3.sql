--Data Cleaning

SELECT *
FROM PortfolioProject..NashvilleHousing

--1. STANDARDIZE THE DATE FORMAT
--OPTION 1 : USE CONVERT() FUNCTION
--OPTION 2: USE ALTER TO CREATE A COLUMN AND SET IT TO UPDATED FORMATTED DATE

SELECT SaleDate, CONVERT(DATE, SaleDate)
FROM PortfolioProject..NashvilleHousing

ALTER TABLE PortfolioProject..NashvilleHousing
ADD SaleDateConverted Date

UPDATE NashvilleHousing
SET SaleDateConverted = Convert(Date, SaleDate)


--2. populate the Null property address
SELECT *
FROM PortfolioProject..NashvilleHousing
--where PropertyAddress is null
order by ParcelID

--self join and writing a subquery

--select tab1.ParcelID, tab1.PropertyAddress, tab2.ParcelID, tab2.PropertyAddress, ISNULL(tab1.PropertyAddress, tab2.PropertyAddress)
--from PortfolioProject..NashvilleHousing tab1
--join PortfolioProject..NashvilleHousing tab2
--on tab1.ParcelID = tab2.ParcelID
--and tab1.[UniqueID ] <> tab2.[UniqueID ]
--where tab1.PropertyAddress is null

UPDATE tab1
SET PropertyAddress = ISNULL(tab1.PropertyAddress, tab2.PropertyAddress)
FROM PortfolioProject..NashvilleHousing tab1
JOIN PortfolioProject..NashvilleHousing tab2
	on tab1.ParcelID = tab2.ParcelID
	AND tab1.[UniqueID ] <> tab2.[UniqueID ]
WHERE tab1.PropertyAddress is null


-- 3.breaking the address columns
--select substring(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1) as Address,
--substring(PropertyAddress,CHARINDEX(',',PropertyAddress)+1, LEN(PropertyAddress)) as City
--from PortfolioProject..NashvilleHousing

ALTER TABLE PortfolioProject..NashvilleHousing
ADD PropertySplitAddress nvarchar(255);

ALTER TABLE PortfolioProject..NashvilleHousing
ADD PropertySplitCity nvarchar(255);

UPDATE NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1) ,
	PropertySplitCity = SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1, LEN(PropertyAddress))

-- Another way of splitting the column : ParseName
SELECT OwnerAddress,
	PARSENAME(REPLACE(OwnerAddress,',','.'),3),
	PARSENAME(REPLACE(OwnerAddress,',','.'),2),
	PARSENAME(REPLACE(OwnerAddress,',','.'),1)
FROM PortfolioProject..NashvilleHousing

ALTER TABLE PortfolioProject..NashvilleHousing
ADD OwnerSplitAddress NVARCHAR(255);

ALTER TABLE PortfolioProject..NashvilleHousing
ADD OwnerSplitCity NVARCHAR(255);

ALTER TABLE PortfolioProject..NashvilleHousing
ADD OwnerSplitState NVARCHAR(255);

UPDATE PortfolioProject..NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',','.'),3),
	OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',','.'),2),
	OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',','.'),1)

-- CLEAN Y/N IN SOLDASVACANT COLUMN

SELECT DISTINCT SoldAsVacant , COUNT(SoldAsVacant)
FROM PortfolioProject..NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2

--USING CASE STATEMENT
--SELECT SoldAsVacant,
--	CASE WHEN SoldAsVacant = 'Y' THEN 'YES'
--		 WHEN SoldAsVacant = 'N' THEN 'NO'
--		 ELSE SoldAsVacant
--		 END
--FROM PortfolioProject..NashvilleHousing

UPDATE PortfolioProject..NashvilleHousing
SET SoldAsVacant =
CASE WHEN SoldAsVacant = 'Y' THEN 'YES'
	WHEN SoldAsVacant = 'N' THEN 'NO'
	ELSE SoldAsVacant
	END




-- REMOVING THE DUPLICATES IN THE DATA
SELECT * INTO Housing FROM PortfolioProject..NashvilleHousing;

--CTE AND SOME WINDOW FUNCTIONS TO FIND WHERE ARE DUPLICATE VALUES

WITH RowNumCTE AS(
SELECT *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SaleDate,
				 SalePrice,
				 LegalReference
				 ORDER BY
					UniqueID) row_num
FROM PortfolioProject..NashvilleHousing)
SELECT * 
FROM RowNumCTE
WHERE row_num > 1

WITH RowNumCTE AS(
SELECT *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SaleDate,
				 SalePrice,
				 LegalReference
				 ORDER BY
					UniqueID) row_num
FROM PortfolioProject..NashvilleHousing)
DELETE
FROM RowNumCTE
WHERE row_num > 1

--------
--delete unused columns

ALTER TABLE PortfolioProject..NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

ALTER TABLE PortfolioProject..NashvilleHousing
DROP COLUMN SaleDate

SELECT *
FROM PortfolioProject..NashvilleHousing
