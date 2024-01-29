-- Inspect all data
SELECT *
FROM PortfolioProject..NasvilleHousing

-- Standardise date format
SELECT SaleDate, CONVERT(Date,SaleDate) 
FROM PortfolioProject..NasvilleHousing

  --or

SELECT SaleDate, CAST(SaleDate as date) 
FROM PortfolioProject..NasvilleHousing

-- Add new column with the converted date
ALTER TABLE NasvilleHousing
Add SaleDateConverted Date

Update NasvilleHousing
Set SaleDateConverted = CONVERT(Date,SaleDate)

Select SaleDateConverted
FROM PortfolioProject..NasvilleHousing

-- Populate Poperty Address data
SELECT *
FROM PortfolioProject..NasvilleHousing
WHERE PropertyAddress is NULL

-- Using ParcelID as a reference point to identify NULL PropertyAddress
SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM PortfolioProject..NasvilleHousing a
JOIN PortfolioProject..NasvilleHousing b 
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ]<>b.[UniqueID ]
WHERE a.PropertyAddress is NULL

-- Update NULL PropertyAddress with reference to ParcelID
UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM PortfolioProject..NasvilleHousing a
JOIN PortfolioProject..NasvilleHousing b 
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ]<>b.[UniqueID ]
WHERE a.PropertyAddress is NULL

-- Break out Address into individual columns (Address, City, State)
SELECT
SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress) -1) as Address,
SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress) +1, LEN(PropertyAddress)) as City
FROM PortfolioProject..NasvilleHousing

-- Update table by adding the previous function
ALTER TABLE NasvilleHousing
Add PropertySplitAddress Nvarchar(255)

Update NasvilleHousing
Set PropertySplitAddress = SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress) -1) 

ALTER TABLE NasvilleHousing
Add PropertySplitCity Nvarchar(255)

Update NasvilleHousing
Set PropertySplitCity = SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress) +1, LEN(PropertyAddress))

-- check updated data
Select *
From PortfolioProject..NasvilleHousing

-- Using PARSENAME() to split OwnerAddress
Select 
Parsename(Replace(OwnerAddress, ',', '.'), 3),
Parsename(Replace(OwnerAddress, ',', '.'), 2),
Parsename(Replace(OwnerAddress, ',', '.'), 1)
FROM PortfolioProject..NasvilleHousing	
Order by ParcelID

-- Update table by adding the previous function
ALTER TABLE NasvilleHousing
Add OwnerSplitAddress Nvarchar(255)

Update NasvilleHousing
Set OwnerSplitAddress = Parsename(Replace(OwnerAddress, ',', '.'), 3)

ALTER TABLE NasvilleHousing
Add OwnerSplitCity Nvarchar(255)

Update NasvilleHousing
Set OwnerSplitCity = Parsename(Replace(OwnerAddress, ',', '.'), 2)

ALTER TABLE NasvilleHousing
Add OwnerSplitState Nvarchar(255)

Update NasvilleHousing
Set OwnerSplitState = Parsename(Replace(OwnerAddress, ',', '.'), 1)

-- check updated data
Select *
From PortfolioProject..NasvilleHousing

-- Change Y and N to Yes and No in 'SoldAsVacant'
SELECT SoldAsVacant,
CASE WHEN SoldAsVacant = 'Y' THEN 'YES'
	WHEN SoldAsVacant = 'N' THEN 'NO'
	ELSE SoldAsVacant
	END
FROM PortfolioProject..NasvilleHousing

-- Update table by adding the previous function
Update NasvilleHousing
Set SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'YES'
	WHEN SoldAsVacant = 'N' THEN 'NO'
	ELSE SoldAsVacant
	END

-- check updated data
SELECT DISTINCT SoldAsVacant
FROM PortfolioProject..NasvilleHousing

--to identify duplicates
Select *,
	ROW_NUMBER() OVER (Partition by ParcelID, 
									PropertyAddress,
									SalePrice,
									SaleDate,
									LegalReference
									Order by UniqueID)
									row_num
From PortfolioProject..NasvilleHousing
Order by ParcelID

--remove duplicates
WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER (Partition by ParcelID, 
									PropertyAddress,
									SalePrice,
									SaleDate,
									LegalReference
									Order by UniqueID)
									row_num
From PortfolioProject..NasvilleHousing
)
DELETE
From RowNumCTE
Where Row_num > 1

-- check updated data
WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER (Partition by ParcelID, 
									PropertyAddress,
									SalePrice,
									SaleDate,
									LegalReference
									Order by UniqueID)
									row_num
From PortfolioProject..NasvilleHousing
)
Select *
From RowNumCTE
Where row_num >1
Order by PropertyAddress