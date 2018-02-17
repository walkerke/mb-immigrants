import arcpy
import arcpy.management as mg
import re
import pandas as pd
import os

# mg.CreateFileGDB("data/2016/dissolve", "full.gdb")

gdb = "data/2016/dissolve/full.gdb"

arcpy.env.workspace = gdb

arcpy.env.overwriteOutput = True

# Uncomment and modify below if you want a different random seed; below is the default
arcpy.env.randomGenerator = "1983 ACM599"

# Copy shapefile to geodatabase

arcpy.conversion.FeatureClassToFeatureClass("data/2016/dissolve/full_dissolved_2016.shp", gdb, "full_dasymetric")

# Declare functions

def immigrants_to_xy(layer, out_dir, scaling_factor):
    levels = ["europe", "eastasia", "sasia", "swanaf", "ssafr",
              "latam", "mexico", "canada", "oceania"]
    for level in levels:
        # Add and calculate the new field
        field_name = level + str(scaling_factor)
        mg.AddField(layer, field_name, "SHORT")
        expr = "!{}! / {}".format(level, scaling_factor)
        mg.CalculateField(layer, field_name, expr)
        # Generate the dots
        out_dots = level + str(scaling_factor)
        mg.CreateRandomPoints(out_path = out_dir, out_name = out_dots, 
                              constraining_feature_class = layer, 
                              number_of_points_or_field = field_name)

def xy_to_pandas(layer): 
    layerid = re.sub("\d+", "", layer)
    new_data = []
    proj = layer + "_xy"
    mg.Project(layer, proj, arcpy.SpatialReference(4326))
    cur = arcpy.da.SearchCursor(proj, ["SHAPE@X", "SHAPE@Y"])
    for row in cur: 
        new_row = dict(X = row[0], Y = row[1])
        new_data.append(new_row)
    df = pd.DataFrame(new_data)
    df['level'] = layerid
    return df
    
def combine_and_write(layer_list, out_csv): 
    df = pd.DataFrame(columns = ["X", "Y", "level"])
    for layer in layer_list: 
        level = xy_to_pandas(layer)
        df = df.append(level)
    # Shuffle the rows before writing out
    df = df.sample(frac = 1)
    df.to_csv(out_csv, index = False)
    
###################################################

# First, generate the dots

in_layer = "full_dasymetric"

scales = [20, 25]

for scale in scales: 
    immigrants_to_xy(in_layer, gdb, scale)
    
##############################################

# Then, write to a CSV

for scale in scales: 
    dots = arcpy.ListFeatureClasses('*' + str(scale))
    out_name = "data/2016/immigration" + str(scale) + ".csv"
    combine_and_write(dots, out_name)

