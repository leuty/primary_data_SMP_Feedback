
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

begin

;Read 12km data
dfile_12 = addfile("/project/pr04/davidle/results_clim/lm_c/lffd1993110100c.nc", "r")

topo_12 = dfile_12->HSURF(0,:,:)
land_mask_12 = dfile_12->FR_LAND(0,:,:)
topo_12 = mask(topo_12,(land_mask_12 .gt. 0.5),1)

topo_12 = where(land_mask_12 .lt. 0.5 ,topo_12@_FillValue,topo_12)

pole = dfile_12->rotated_pole
pole_lon = pole@grid_north_pole_longitude
pole_lat = pole@grid_north_pole_latitude

; geo-reference data
topo_12@lat2d = dfile_12->lat
topo_12@lon2d = dfile_12->lon 
topo_12@long_name = ""
topo_12@units      = ""

;Read 2km data
dfile_2 = addfile("/project/pr04/davidle/results_clim/lm_f/lffd1998110100c.nc", "r")

;lm_f indices for various regions
;lm_f doain
xstart=0
xend=1541
ystart=xstart
yend=xend

;analysis domain
;xstart=49
;xend=1491
;ystart=xstart
;yend=xend

;Atlantic
;xstart=180
;xend=400
;ystart=700
;yend=1000

;Alps
;xstart=717
;xend=1138
;ystart=621
;yend=842

;Eastern Europe
;xstart=800
;xend=1491
;ystart=950
;yend=1160

topo_2 = dfile_2->HSURF(0,ystart:yend,xstart:xend)
land_mask_2 = dfile_2->FR_LAND(0,ystart:yend,xstart:xend)
topo_2 = mask(topo_2,(land_mask_2 .gt. 0.5),1)

topo_2 = where(land_mask_2 .lt. 0.5 ,topo_2@_FillValue,topo_2)

pole = dfile_2->rotated_pole
pole_lon = pole@grid_north_pole_longitude
pole_lat = pole@grid_north_pole_latitude

; geo-reference data
topo_2@lat2d = dfile_2->lat(ystart:yend,xstart:xend)
topo_2@lon2d = dfile_2->lon(ystart:yend,xstart:xend)
topo_2@long_name = ""
topo_2@units      = ""

cmap = read_colormap_file("OceanLakeLandSnow") ; read color data
;==============================================================

mpres                       = True
mpres@gsnDraw               = False
mpres@gsnFrame              = False
mpres@tiYAxisString         = ""
mpres@tiXAxisString         = ""
mpres@gsnMaximize           = True

res                         = mpres 

;Define the underlying map
;-------------------------
mpres@mpProjection           = "Mercator"
mpres@mpOutlineBoundarySets  = "National"
mpres@mpDataBaseVersion      = "LowRes"
mpres@mpDataBaseVersion      = "Ncarg4_1"
mpres@mpDataSetName          = "Earth..4"
mpres@pmTickMarkDisplayMode  = "never"
mpres@mpLabelsOn             = False
mpres@mpFillOn               = True 
;mpres@mpOutlineOn            = True
mpres@mpGeophysicalLineThicknessF = 0
mpres@mpNationalLineThicknessF = 4
mpres@mpOutlineDrawOrder     = "PostDraw"
mpres@mpFillDrawOrder        = "PreDraw"
mpres@mpMonoFillColor        = True
;mpres@mpFillColor            = "dodgerblue3"
mpres@mpFillColor            = "royalblue3"

;Rotate pole
;-----------
mpres@mpCenterLonF            = pole_lon + 180.
mpres@mpCenterLatF            = 90. - pole_lat

;2km analysis domain
mpres@mpLimitMode            = "Corners"
mpres@mpLeftCornerLatF       = dfile_12->lat(0,0)
mpres@mpLeftCornerLonF       = dfile_12->lon(0,0)
mpres@mpRightCornerLatF      = dfile_12->lat(360,360)
mpres@mpRightCornerLonF      = dfile_12->lon(360,360)

;Define contours
;----------------

res@gsnAddCyclic          = False
res@cnFillPalette         = cmap(2:,:) ; set color map
res@cnFillOn              = True
res@cnFillMode            = "RasterFill"
;res@cnRasterCellSizeF     = 1.0 /4000.0
res@cnLinesOn             = False

;res@lbLabelBarOn          = False
res@cnInfoLabelOn          = False
res@cnLineLabelsOn         = False
res@lbOrientation          = "vertical"

mnmxint = nice_mnmxintvl( min(topo_2), max(topo_2), 18, False)
res@cnLevelSelectionMode = "ManualLevels"
res@cnMaxLevelValF       = mnmxint(1)
res@cnLevelSpacingF      = mnmxint(2)/2.

wks_type = "png"
;wks_type@wkPaperSize = "A3"
wks_type@wkWidth  = 4000 
wks_type@wkHeight = 4000

wks = gsn_open_wks(wks_type, "/project/pr04/davidle/results_soil-moisture_pertubation/analysis/plots/domain/domain" )

;=============================================================
 map     = gsn_csm_map(wks,mpres)
 plot_12 = gsn_csm_contour(wks,topo_12(:,:),res)
 plot_2  = gsn_csm_contour(wks,topo_2(:,:),res)
;============================================================

overlay(map,plot_12)
overlay(map,plot_2)


draw(map)
frame(wks)


end

