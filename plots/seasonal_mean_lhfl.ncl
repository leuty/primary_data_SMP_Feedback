
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

begin
model="lm_f"

dfilename = getenv("NCL_ARG_2")
cfilename = getenv("NCL_ARG_3")
filename = getenv("NCL_ARG_4")


dfile = addfile(dfilename, "r")
cfile = addfile(cfilename, "r")

p = dfile->ALHFL_S(0,:,:)
land_mask = cfile->FR_LAND(0,:,:)
p=(-1) * p

pole = cfile->rotated_pole
pole_lon = pole@grid_north_pole_longitude
pole_lat = pole@grid_north_pole_latitude

; read lat/lon arrays
p@lat2d = cfile->lat
p@lon2d = cfile->lon

p@long_name  = ""
p@units      = ""

;==============================================================

res                       = True
res@tiYAxisString         = ""
res@tiXAxisString         = ""
res@gsnMaximize           = True
res@gsnPaperOrientation   = "portrait"
res@gsnDraw               = False
res@gsnFrame              = False

;Define the underlying map   
;-------------------------   
res@mpProjection           = "Mercator"
res@mpOutlineBoundarySets  = "National"
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

;Rotate pole
;-----------
res@mpCenterLonF            = pole_lon + 180.
res@mpCenterLatF            = 90. - pole_lat

;2km analysis domain
res@mpLimitMode            = "Corners"
res@mpLeftCornerLatF       = 32.1166
res@mpLeftCornerLonF       = -9.43726
res@mpRightCornerLatF      = 59.5612
res@mpRightCornerLonF      = 28.9279

;Define contours
;----------------

res@cnFillOn                = True
res@cnFillMode              = "CellFill"
res@cnLinesOn               = False

;res@lbLabelBarOn           = False
res@cnInfoLabelOn          = False
res@cnLineLabelsOn         = False
res@lbOrientation          = "vertical"
res@gsnSpreadColors        = True


res@cnLevelSelectionMode   = "ManualLevels"
res@cnMinLevelValF         = 20 
res@cnMaxLevelValF         = 120
res@cnLevelSpacingF        = 20



wks_type = "png"
wks_type@wkWidth = 3600
wks_type@wkHeight = 3600
wks = gsn_open_wks("png", filename )
gsn_define_colormap(wks,"MPL_viridis")
gsn_reverse_colormap(wks)

;=============================================================
plot = gsn_csm_contour_map(wks,p(:,:),res)
;============================================================

draw(plot)
frame(wks)


end

