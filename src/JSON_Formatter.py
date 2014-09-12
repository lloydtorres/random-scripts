#!/usr/bin/python

# JSON Formatter, by Lloyd Torres
# Quick way of taking a JSON file written in one line
# and formatting it nicely. Licensed under MIT License.

# Known issues:
# - Does not nest arrays of objects properly

# Changelog:
# 1.0 - Initial version
# 1.1 - Fixed bug where recursiveBracket() did not count numbber
#       of closing brackets

import sys # sys used for command line arguments

bracketLevel = 1 # amount of tabs a line needs

# used to format entries that have other objects in them
def recursiveBracket(toRead):
    global bracketLevel

    toRead = toRead.split("{",1)
    outFile.write("\t"*bracketLevel + toRead[0].strip() + " {\n")
    bracketLevel += 1

    if toRead[1].find("{") != -1: # means another object is in property
        recursiveBracket(toRead[1])
    elif toRead[1].find("}") != -1: # means only entry in property
        noCloses = toRead[1].count("}")
        outFile.write("\t"*(bracketLevel) + toRead[1].strip().replace("}","") + ",\n")
        for i in range(0,noCloses):
            bracketLevel -= 1
            outFile.write("\t"*bracketLevel + "}\n")
    else:
        outFile.write("\t"*bracketLevel + toRead[1].strip() + ",\n")

if len(sys.argv) != 0: # Make sure there's command line arguments
    checkArg = sys.argv[1].strip()
    if checkArg[len(checkArg)-5:] == ".json": # Make sure argument is actually json file
        # Open file in argument
        inFile = open(checkArg)
        fileContents = inFile.readline().split(",")
        inFile.close()

        # Remove first instance of {, last instance of }
        for f in range(0,len(fileContents)):
            if fileContents[f].find("{") != -1:
                fileContents[f] = fileContents[f].replace("{","",1)
                break

        for l in range(len(fileContents)-1,-1,-1):
            if fileContents[l].find("}") != -1:
                fileContents[l] = fileContents[l].replace("}","",1)
                break

        # Open write file
        name = checkArg[:len(checkArg)-5] # get rid of extension
        
        outFile = open(name + "_format.json","w")
        outFile.write("{\n")

        # Actual processing
        for entry in fileContents:
            entry = entry.strip()
            
            if entry.find("{") != -1: # leading brackets
                recursiveBracket(entry)
            elif entry.find("}") != -1: # closing brackets
                noBrackets = entry.count("}")
                entry = entry.replace("}","")
                
                outFile.write("\t"*bracketLevel + entry + "\n")
                for i in range(0,noBrackets): # sets closing brackets
                    bracketLevel -= 1
                    outFile.write("\t"*bracketLevel + "}\n")
            else:
                outFile.write("\t"*bracketLevel + entry + ",\n")

        outFile.write("}")
        outFile.close()

    else:
        print("ERROR: Not a JSON file.")
else:
    print("ERROR: No arguments found.")
        
