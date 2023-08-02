import os, sys


# =============================================================================
# INPUT
# =============================================================================
sys_path_PSSE = r'C:\Program Files\PTI\PSSE35\35.3\PSSPY37'  #or where else you find the psspy.pyc (Please change this to your own directory)
sys.path.append(sys_path_PSSE)
PSSE_LOCATION = r"C:\Program Files\PTI\PSSE35\35.3\PSSBIN" #(Please change this to your own directory)
sys.path.append(PSSE_LOCATION)
os.environ['PATH'] = os.environ['PATH'] + ';' +  PSSE_LOCATION

local_dir = os.getcwd()
sys.path.append(local_dir)
os.environ['PATH'] += ';' + local_dir

import psse35
import psspy
psspy.psseinit(200000)

_i = psspy.getdefaultint()
_f = psspy.getdefaultreal()
_s = psspy.getdefaultchar()





local_dir = os.getcwd()
rawFilePath = local_dir + '\\' + 'IEEE39bus_original_Modified_v34.raw'
dyrFilePath = local_dir + '\\' + 'IEEE39bus_original_Modified5_only_TGOV1' 
outFilePath = local_dir + '\\' + 'IEEE39bus_original.out' 
csvFilePath = local_dir + '\\' + 'PSSE.csv' 

eventStartTime = 20
eventEndTime = 20.1
simEndTime = 50
faultBusNum = 16
tripGenBusNum = 32
tripGenBusId = '1'
invBusId = '1'

eventType = 1 # 0->fault, 1->generator trip

psspy.psseinit(1000000)
psspy.readrawversion(0, '35', rawFilePath)
psspy.fnsl([0,0,0,1,0,0,0,0])     # Power Flow setting
psspy.cong(0)  # conversion for dynamic simulation
psspy.conl(0,1,1,[0,0],[ 0,100,0, 100])
psspy.conl(0,1,2,[0,0],[ 0,100,0, 100])
psspy.conl(0,1,3,[0,0],[ 0,100,0, 100])
psspy.dyre_new([1,1,1,1],dyrFilePath,"","","")

psspy.snap([-1,-1,-1,-1,-1],"GFMI_new.snp") #I changed chnnel slots due to my license limitation - by Sam Seo)
psspy.chsb(0,1,[-1,-1,-1,1,1,0])
psspy.chsb(0,1,[-1,-1,-1,1,2,0])
psspy.chsb(0,1,[-1,-1,-1,1,3,0])
psspy.chsb(0,1,[-1,-1,-1,1,4,0])
psspy.chsb(0,1,[-1,-1,-1,1,5,0])
psspy.chsb(0,1,[-1,-1,-1,1,6,0])
psspy.chsb(0,1,[-1,-1,-1,1,7,0])
psspy.chsb(0,1,[-1,-1,-1,1,13,0])


""" Running dynamic simulation """
psspy.dynamics_solution_param_2([99,_i,_i,_i,_i,_i,_i,_i],[ 1.0,_f, 0.004166,0.016664,_f,_f,_f,_f])
psspy.strt_2([1, 0],outFilePath)


psspy.run(0, eventStartTime,999,1,999)
if eventType == 0:
    ierr = psspy.dist_bus_fault(faultBusNum, 3, 0, [0.0,0.1])

elif eventType ==1:
    ierr = psspy.dist_machine_trip(tripGenBusNum, tripGenBusId)

psspy.run(0, eventEndTime,999,1,999)

if eventType == 0:
    ierr = psspy.dist_clear_fault(1)

psspy.run(0, simEndTime,999,1,999)


import dyntools
import pandas as pd
chnfobj = dyntools.CHNF(outFilePath)
sh_ttl, ch_id, ch_data = chnfobj.get_data()
plot_chns = list(range(1, len(ch_id)))
csv_dict = {}
time = ch_data['time']
csv_dict['time'] = time
for chn_idx in plot_chns:
	csv_dict[ch_id[chn_idx]] = ch_data[chn_idx]
df = pd.DataFrame(csv_dict)
df.to_csv(csvFilePath, index=False)