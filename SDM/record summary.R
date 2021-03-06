### Transform Bionet NSW data  - some species in the whole NSW ---------------------------------------------------
require(rgdal)
require(raster)


folder = "Data/presence records/21_06/"

cumberland_shape = readOGR("Data/Data package 20180309/Cumberland_IBRA_subregion.shp")

sdm_nsw = readOGR("Data/presence records/Bionet_records.shp")
proj4string(sdm_nsw)=cumberland_shape@proj4string


vegetation_shape = readOGR("Data/Vegetation_100kbuffer_cumberland/IndCreditSum_State_BioisisVeg_simplified_4283.shp")
proj4string(vegetation_shape)=cumberland_shape@proj4string

cumberland_buffer = readOGR("Data/Cumberland buffer/cumberland_buffer_1.shp")
proj4string(cumberland_buffer)=cumberland_shape@proj4string

vegetation_cumberland = crop(vegetation_shape, cumberland_shape)

# sdm_nsw_table = sdm_nsw@data
# sdm_nsw_names = unique(sdm_nsw_table$scientific)

# write.csv(sdm_nsw_names, file= paste(folder, "all_species_names.csv", sep=""))
# write.csv(sdm_nsw_table, file=paste(folder, "sdm_nsw.csv", sep=""))


inside_cumberland = !is.na(over(sdm_nsw, as(cumberland_shape, "SpatialPolygons")))
inside_cumberland_vegetation = !is.na(over(sdm_nsw, as(vegetation_cumberland, "SpatialPolygons")))

inside_buffer = !is.na(over(sdm_nsw, as(cumberland_buffer, "SpatialPolygons")))
inside_buffer_vegetation = !is.na(over(sdm_nsw, as(vegetation_shape, "SpatialPolygons")))

# inside_buffer = !is.na(over(sdm_nsw, as(buffer_shape, "SpatialPolygons")))



sdm_cumberland = sdm_nsw[inside_cumberland,]
sdm_cumberland_table = sdm_cumberland@data
sdm_cumberland_names = unique(sdm_cumberland_table$scientific)
write.csv(sdm_cumberland_table, file=paste(folder, "sdm_cumberland.csv", sep=""))

sdm_cumberland_vegetation = sdm_nsw[inside_cumberland_vegetation,]
sdm_cumberland_vegetation_table = sdm_cumberland_vegetation@data
sdm_cumberland_vegetation_names = unique(sdm_cumberland_vegetation_table$scientific)
write.csv(sdm_cumberland_vegetation_table, file=paste(folder, "sdm_cumberland_vegetation.csv", sep=""))

sdm_buffer_vegetation = sdm_nsw[inside_buffer_vegetation&!inside_cumberland,]
sdm_buffer_vegetation_table = sdm_buffer_vegetation@data
sdm_buffer_vegetation_names = unique(sdm_buffer_vegetation_table$scientific)
write.csv(sdm_buffer_vegetation_table, file=paste(folder, "sdm_buffer_vegetation.csv", sep=""))



sdm_buffer = sdm_nsw[inside_buffer&!inside_cumberland,]
sdm_buffer_table = sdm_buffer@data
sdm_buffer_names = unique(sdm_buffer_table$scientific)
write.csv(sdm_buffer_table, file=paste(folder, "sdm_buffer.csv", sep=""))




sdm_outside = sdm_nsw[!(inside_cumberland|inside_buffer_vegetation|inside_buffer),]
sdm_outside_table=sdm_outside@data
sdm_outside_names = unique(sdm_outside_table$scientific)
write.csv(sdm_outside_table, file=paste(folder, "sdm_outside.csv", sep=""))



write(
	"Code name, Sientific name, Common name, Order, Kingdom, 	Total, <1000,  No. Cumberland, <1000, No. Cubmerland Vegetation, <1000,  No. Buffer, <1000,   No. BUffer Vegetation,  <1000,  No. out Cumberland , <1000",
	file = paste(folder, "species_records_summary_veg_100kbuffer.csv", sep = ""))





sdm_nsw_species=NULL
for (i in sdm_nsw_names)
{
	all = sdm_nsw_table[sdm_nsw_table$scientific == i, ]
	cumberland = sdm_cumberland_table[sdm_cumberland_table$scientific == i, ]
	cumberland_vegetation = sdm_cumberland_vegetation_table[sdm_cumberland_vegetation_table$scientific == i, ]

	buffer = sdm_buffer_table[sdm_buffer_table$scientific == i, ]
	buffer_vegetation = sdm_buffer_vegetation_table[sdm_buffer_vegetation_table$scientific == i, ]


	outside = sdm_outside_table[sdm_outside_table$scientific == i, ]

	common_name =  unique(sdm_nsw_table[sdm_nsw_table$scientific == i, 'vernacular'])
	common_name  = gsub(",", ";" , common_name , ignore.case = TRUE)

	family =  unique(sdm_nsw_table[sdm_nsw_table$scientific == i, 'order_'])
	kingdom =  unique(sdm_nsw_table[sdm_nsw_table$scientific == i, 'kingdom'])

	name = i
	# remove special characters, spaces, douple underscores and trailing unserscores
	name  = gsub("[^0-9A-Za-z]","_" , name ,ignore.case = TRUE)
	name  = gsub("__","_" , name ,ignore.case = TRUE)
	name  = gsub("_$","" , name ,ignore.case = TRUE)
	name  = gsub("^_","" , name ,ignore.case = TRUE)

	sdm_nsw_species=c(sdm_nsw_species, name)

	do.call('=',list(name,all))


	# write.csv(all, file=paste( folder, "all_csv/",name,".csv", sep=""))
	# write.csv(cumberland, file = paste(folder, "cumberland_csv/", name, ".csv", sep = ""))
	# write.csv(cumberland_vegetation, file=paste( folder, "cumberland_vegetation_csv/",name,".csv", sep=""))
	# write.csv(buffer, file=paste( folder, "inside_buffer_csv/",name,".csv", sep=""))
	# write.csv(buffer_vegetation, file=paste( folder, "inside_buffer_vegetation_csv/",name,".csv", sep=""))
	# write.csv(outside, file=paste(folder, "outside_csv/",name,".csv", sep=""))



	# Total,
	#<1000,
	# No. in Cumberland,
	#<1000,
	# No. in Cubmerland Vegetation,
	#<1000
	# No. Buffer
	#<1000,
	# No. BUffer Vegetation,
	#<1000
	# No. out Cumberland",
	#<1000
	# class(all)
	# as.numeric(all[,'coordina_1'])<1000
	all1000 = all[as.numeric(as.character(all$coordina_1))<=1000,]
	cumberland1000 = cumberland[as.numeric(as.character(cumberland$coordina_1))<=1000,]
	cumberland_vegetation1000 = cumberland_vegetation[as.numeric(as.character(cumberland_vegetation$coordina_1))<=1000,]
	buffer1000 = buffer[as.numeric(as.character(buffer$coordina_1))<=1000,]
	buffer_vegetation1000 = buffer_vegetation[as.numeric(as.character(buffer_vegetation$coordina_1))<=1000,]
	outside1000 = outside[as.numeric(as.character(outside$coordina_1))<=1000,]

	str = paste(name, i, common_name, family, kingdom,
							dim(all)[1],
							dim(all1000)[1],

							dim(cumberland)[1],
							dim(cumberland1000)[1],

							dim(cumberland_vegetation)[1],
							dim(cumberland_vegetation1000)[1],

							dim(buffer)[1],
							dim(buffer1000)[1],

							dim(buffer_vegetation)[1],
							dim(buffer_vegetation1000)[1],

							dim(outside)[1],
							dim(outside1000)[1],

							sep="," )

	write(str ,file=paste(folder, "species_records_summary_veg_100kbuffer.csv", sep =""), append=TRUE)
}











