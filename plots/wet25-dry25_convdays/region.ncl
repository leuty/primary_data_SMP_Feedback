
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

begin

dfilename = getenv("NCL_ARG_2")
cfilename = getenv("NCL_ARG_3")
filename = getenv("NCL_ARG_4")

dfile = addfile(dfilename + ".nc", "r")
cfile = addfile(cfilename, "r")

p = dfile->MASK(:,:)
;p = dfile->MASK(0,:,:)

pole = cfile->rotated_pole
pole_lon = pole@grid_north_pole_longitude
pole_lat = pole@grid_north_pole_latitude

lat2d = cfile->lat
lon2d = cfile->lon

; geo-reference data
p@lat2d = lat2d
p@lon2d = lon2d
p@long_name = ""
p@units      = ""

;==============================================================

res                       = True
res@gsnDraw               = False
res@gsnFrame              = False
res@tiYAxisString         = ""
res@tiXAxisString         = ""
res@gsnMaximize           = True
res@gsnPaperOrientation   = "portrait"
res@gsnAddCyclic          = False

ures                      = res
tres                      = res

;Define the underlying map
;-------------------------
res@mpProjection           = "Mercator"
;res@mpOutlineBoundarySets  = "National"
res@mpDataBaseVersion      = "HighRes"
res@mpDataBaseVersion      = "Ncarg4_1"
res@mpDataSetName          = "Earth..4"
res@pmTickMarkDisplayMode  = "never"
res@mpLabelsOn             = False
res@mpFillOn               = True
res@mpOutlineOn            = True
res@mpOutlineDrawOrder     = "PostDraw"
res@mpFillDrawOrder        = "PreDraw"
res@mpOceanFillColor       = "grey78"
res@mpLandFillColor        = "white"

;Rotate pole
;-----------
res@mpCenterLonF            = pole_lon + 180.
res@mpCenterLatF            = 90. - pole_lat
;res@tfDoNDCOverlay          = False

;2km analysis domain
res@mpLimitMode            = "Corners"
res@mpLeftCornerLatF       = 41.5
res@mpLeftCornerLonF       = 1
res@mpRightCornerLatF      = 51
res@mpRightCornerLonF      = 20


;Define contours
;----------------

res@cnFillOn                = True
res@cnFillMode              = "CellFill"
res@cnLinesOn               = False

res@lbLabelBarOn           = False
res@cnInfoLabelOn          = False
res@cnLineLabelsOn         = False
res@lbOrientation          = "vertical"
res@gsnSpreadColors        = True

wks = gsn_open_wks("png", filename )
gsn_define_colormap(wks,"MPL_Greys")
res@cnFillOpacityF 	   = 0.85

res@cnLevelSelectionMode   = "ManualLevels"
res@cnMinLevelValF         = 0
res@cnMaxLevelValF         = 1
res@cnLevelSpacingF        = 0.2 

;=============================================================
plot= gsn_csm_contour_map(wks,p(:,:),res)
;============================================================


draw(plot)
frame(wks)


end

