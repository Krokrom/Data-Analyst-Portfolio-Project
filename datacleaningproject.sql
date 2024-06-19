/*
Data cleaning of households
*/

select *
from PortfolioProject.dbo.NashvilleHousing


--Standardizing Data Format

select SaleDateConverted
from PortfolioProject.dbo.NashvilleHousing

Update PortfolioProject.dbo.NashvilleHousing
set SaleDate = convert(date, SaleDate)

alter table PortfolioProject.dbo.NashvilleHousing
add SaleDateConverted date;

Update PortfolioProject.dbo.NashvilleHousing
set SaleDateConverted = convert(date, SaleDate)



--Populating Missing Property Addresses

select * 
from PortfolioProject..NashvilleHousing
--where PropertyAddress is null
order by ParcelID




select nasha.ParcelID, nasha.PropertyAddress, nashb.ParcelID, nashb.PropertyAddress, isnull(nasha.PropertyAddress, nashb.PropertyAddress)
from PortfolioProject..NashvilleHousing as nasha
join PortfolioProject..NashvilleHousing as nashb
	on nasha.ParcelID = nashb.ParcelID
	and nasha.[UniqueID ] <> nashb.[UniqueID ]
where nasha.PropertyAddress is null


update nasha
set PropertyAddress = isnull(nasha.PropertyAddress, nashb.PropertyAddress)
from PortfolioProject..NashvilleHousing as nasha
join PortfolioProject..NashvilleHousing as nashb
	on nasha.ParcelID = nashb.ParcelID
	and nasha.[UniqueID ] <> nashb.[UniqueID ]
where nasha.PropertyAddress is null




--Categorizing Addresses

select PropertyAddress
from PortfolioProject..NashvilleHousing

select
substring(PropertyAddress, 1, CHARINDEX(',',PropertyAddress) -1) as Address
, substring(PropertyAddress,CHARINDEX(',',PropertyAddress) +1, LEN(PropertyAddress)) as City


from PortfolioProject..NashvilleHousing

alter table PortfolioProject.dbo.NashvilleHousing
add PropertySplitAddress nvarchar(255);

update PortfolioProject.dbo.NashvilleHousing
set PropertySplitAddress = substring(PropertyAddress, 1, CHARINDEX(',',PropertyAddress) -1)

alter table PortfolioProject..NashvilleHousing
add PropertySplitCity nvarchar(255);

update PortfolioProject.dbo.NashvilleHousing
set PropertySplitCity = substring(PropertyAddress,CHARINDEX(',',PropertyAddress) +1, LEN(PropertyAddress))

select *
from PortfolioProject.dbo.NashvilleHousing

--Categorizing Owner Addresses

select OwnerAddress
from PortfolioProject.dbo.NashvilleHousing

select 
PARSENAME(REPLACE(OwnerAddress, ',', '.'),3) as addresses
, PARSENAME(REPLACE(OwnerAddress, ',', '.'),2) as cities
, PARSENAME(REPLACE(OwnerAddress, ',', '.'),1) as states
from PortfolioProject.dbo.NashvilleHousing


alter table PortfolioProject.dbo.NashvilleHousing
add OwnerSplitAddress nvarchar(255);

update PortfolioProject.dbo.NashvilleHousing
set OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'),3)

alter table PortfolioProject..NashvilleHousing
add OwnerSplitCity nvarchar(255);

update PortfolioProject.dbo.NashvilleHousing
set OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'),2)

alter table PortfolioProject.dbo.NashvilleHousing
add OwnerSplitStates nvarchar(255);

update PortfolioProject.dbo.NashvilleHousing
set OwnerSplitStates = PARSENAME(REPLACE(OwnerAddress, ',', '.'),1)

select *
from PortfolioProject.dbo.NashvilleHousing



-- Changing "Sold as Vacant" field values (changing y and n to yes and no)

select distinct(SoldAsVacant), count(SoldAsVacant)
from PortfolioProject.dbo.NashvilleHousing
group by SoldAsVacant
order by 2



select SoldAsVacant
,	case when SoldAsVacant = 'Y' then 'Yes'
		 when SoldAsVacant = 'N' then 'No'
		 else SoldAsVacant
		 end
from PortfolioProject.dbo.NashvilleHousing


update PortfolioProject..NashvilleHousing
set SoldAsVacant = case when SoldAsVacant = 'Y' then 'Yes'
		 when SoldAsVacant = 'N' then 'No'
		 else SoldAsVacant
		 end



--Removing duplicates
with RowNumCTE AS(
select *,
	row_number() OVER (
	partition by ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 order by
					UniqueID
					) as row_num
				
from PortfolioProject..NashvilleHousing
--order by ParcelID
)


select *
from RowNumCTE
where row_num > 1
order by ParcelID




--Delete unused columns

select *
from PortfolioProject.dbo.NashvilleHousing

alter table PortfolioProject.dbo.NashvilleHousing
DROP COLUMN PropertyAddress, OwnerAddress, TaxDistrict


alter table PortfolioProject.dbo.NashvilleHousing
DROP COLUMN SaleDate