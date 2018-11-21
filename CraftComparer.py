'''
KSP part mapper and comparison program
Written by Servo, Nov. 2018

Version 1.1
> removed odd coding practics (generator loops)
> added ability to update trials and sensitivity on the fly
> improved initial info
'''
version = 1.1
import os
import random

TRIALS = 100 #number of tests
SENSITIVITY = 1 #relatively how small the search window is
MINHITPERC = .25 #for auto-checking, percentage similarity that is notworthy

def printCraft(craft):
    for x in range(len(craft)):
        print("(%3d): %s" % (x+1, craft[x].strip(".craft")))
    #print each craft with its corresponding number

def compareCraft(closerLook,trials = TRIALS,sens = SENSITIVITY,output=True):
    files = [open(closerLook[0],'r'),open(closerLook[1],'r')]
    craftOne = files[0].readlines()
    craftTwo = files[1].readlines()
    for x in files: x.close() 
    #open the files, then copy their contents into two lists before closing them
    
    craftOne = cleanCraft(craftOne)
    craftTwo = cleanCraft(craftTwo)
    #clean the files into long strings that are useful for looking through

    hits = 0
    for x in range(0,trials): #for each trial
        window = int(random.randint(20,100) * sens) #generate a random window size
        a = random.randint(0,len(craftOne) - window) 
        rTest = craftOne[a:a+window] #determine where in the long craft string we're looking with that window
        
        hits += (rTest in craftTwo) #if that segment is in the second craft string, register a hit
        
    if output:
        print("hits: %d\ntrials: %d\n%s%4.2f similarity" % (hits, trials,'%', hits/trials * 100))
    return hits, trials
    
def cleanCraft(craft):
    cleanedCraft = craft[0:10] #grab the header, start the new list with it

    for index in range(len(craft)):
        if craft[index] == "PART\n": #look for each separate part
            cleanedCraft += [craft[index + 2:index+14]] #grab the following 12 lines. This is where the location and rotation data are
    cleanedCraftString = ''.join([''.join(x) for x in cleanedCraft]) #mash everything into one big string
    return cleanedCraftString
            

#scan the directory for relevant files
print("KSP .craft similarity checker by Servo V%3.2f\n" % version)
print("file location: ", os.getcwd())
tree = list(os.walk('.'))[0][2] #grab every file name in the local directory
craft = list(filter(lambda x: '.craft' in x, tree)) #get a list of only files with the .craft extension
del(tree) #kill this to free memory. I doubt that this does much, but it feels good

inp = 'h' #start by showing the help screen
while inp != 'x': #break with X
    if inp and inp[0] == 'h':
        print("[S]how: show craft ID numbers\n[#1 #2]: compare craft #s 1 and 2")
        print("[A]ll: compare ALL craft in current folder. WARNING: this takes a while")
        print("[U]pdate: change sensitivity values and trial size")
        
    if inp and inp[0] == 's': #show all craft numbers. First line is error handling against empty strings
        printCraft(craft)

                    #check two specific craft using numeric IDs
    if inp and all([x.isnumeric() for x in inp.split()]) and len(inp.split()) == 2: #grab only inputs that are two integers
        closerLookNums = [int(x)-1 for x in inp.split()]
        if all([x <= len(craft) and x >= 0 for x in closerLookNums]): #ensure that two unique, valid numbers were inputted
            if closerLookNums[0] == closerLookNums[1]: #prevents checking the same craft
                print("same craft!")
                inp = ' ' #error handling line here. Forces inp to reset so the continue doesn't screw things up
                continue
            closerLook = (craft[closerLookNums[0]],craft[closerLookNums[1]])
            printCraft(closerLook) 
            compareCraft(closerLook,trials = TRIALS,sens = SENSITIVITY) #compare the two indicated craft
        else:
            print("out of range!")
    
    if inp and inp[0] == 'a': #check all craft in the current directory
        for x in range(0,len(craft)):
            for y in range(x,len(craft)):
                if x != y: #scan every unique combination of craft files
                    hits,trials = compareCraft([craft[x],craft[y]],output = False,trials = TRIALS,sens = SENSITIVITY)
                    if hits/trials > MINHITPERC: #if the percentage is high enough, indicate as much
                        print("potential copy between %s and %s. \nsimilarity: %s%4.2f\n"
                              % (craft[x][0:-6],craft[y][0:-6],'%',hits/trials*100))
                        
    if inp and inp[0] == 'u':
         print("update values using 'letter new_value' form")
         print("[T]rials: %d\n[S]ensitivity: %4.2f\n[M]inimum significance: %2.2f" % (TRIALS,SENSITIVITY,MINHITPERC))
         inp = input().lower()
         while inp and (inp[0] in ['t','s','m']) and (len(inp) > 2):
            out = inp.split()
            try:
                newNum = float(out[1])

                if inp[0] == 't':
                    if newNum > 50:
                        TRIALS = int(newNum)
                    else:
                        print("greater than 50 trials are recommended trials")

                if inp[0] == 's':
                    if newNum > 0 and newNum < 5:
                        SENSITIVITY = newNum
                    else:
                        print("choose a value between 0 and 5")
                        
                if inp[0] == 'm':
                    if newNum > 0 and newNum < 1:
                        MINHITPERC = newNum
                    else:
                        print("value must be between 0 and 1")

            except:
                print("invalid new value")
                
            
             
            inp = input().lower()    


    #get a new input line
    inp = input('.\n').lower()
