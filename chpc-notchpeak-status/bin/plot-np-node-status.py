#!/uufs/chpc.utah.edu/sys/installdir/r8/python/3.10.3/bin/python
###!/packages/envs/scicomp/bin/python
"""
VERSION: 0.8
BLAME: Jason <yalim@asu.edu>
"""
import plotly
import plotly.express as px
import pandas as pd
import numpy as np
import sys

datafile = sys.argv[1]
if len(sys.argv) > 2:
  statfile = sys.argv[2]
  statdict = pd.read_csv(statfile,names='U R PD T'.split(),delim_whitespace=True).to_dict(orient='records')[0]
  stat_str = 'Queue stats: {U} Researchers, {R}/{PD}/{T} Run/Pend/Tot. Jobs'.format(**statdict)
else:
  stat_str = ''

__ANIM_MODE__ = True if len(sys.argv) > 3 else False

now = pd.Timestamp.now().strftime('%F %T')

COLS=[
  'NODELIST',
  'STATE',
  'PARTITION',
  'ALLOC_CPUS',
  'CPUS',
  'ALLOCMEM',
  'MEMORY',
  'ACTIVEMEM',
  'CPU_LOAD',
  'AVAIL_FEATURES',
  'SPECIAL',
  'gpu_str',
]

gpu_status_symbol = dict(idle='○',alloc='●')

BASE_WIDTH= 76 # HORZ PIXELS PER NODE 
BASE_DEPTH= 70 # VERT PIXELS PER NODE 
FONTSIZE  = 12

def mig_disk(center=np.r_[0,0], radius=1, alloc_mig=[], max_mig=7, n=720):
  # Draw main GPU circle
  OX,OY = center
  th = np.linspace(0,1,n+1,dtype=np.float64)[:-1]*2*np.pi
  x  = center + radius*np.c_[np.cos(th),np.sin(th)]
  pdisk = f"M {x[0,0]:6.3e},{x[0,1]:6.3e}" 
  for xc in x[1:]:
    pdisk += f" L{xc[0]:6.3e},{xc[1]:6.3e}"
  pdisk += f" L{x[0,0]:6.3e},{x[0,1]:6.3e} Z"
  psegs = []
  # Draw MIG segments
  if len(alloc_mig) > 0:
    ori   = f'L{OX:6.3e},{OY:6.3e}'
    rads0 = np.array(alloc_mig)/max_mig * 2 * np.pi
    radsN = rads0 + 2*np.pi/max_mig
    X0    = center+radius*np.c_[np.cos(rads0),np.sin(rads0)]
    XN    = center+radius*np.c_[np.cos(radsN),np.sin(radsN)]
    for k in range(len(X0)):
      x0,y0 = X0[k]
      xN,yN = XN[k]
      th    = np.linspace(rads0[k],radsN[k],11)[1:-1][::-1]
      xx    = center + radius*np.c_[np.cos(th),np.sin(th)]
      pseg  = f'M {x0:6.3e},{y0:6.3e} {ori} L{xN:6.3e},{yN:6.3e}'
      for x_ in xx:
        pseg += f' L{x_[0]:6.3e},{x_[1]:6.3e}'
      pseg += f' L{x0:6.3e},{y0:6.3e} Z'
      psegs.append(pseg)
  return pdisk,psegs

def get_gpu_str(rdf):
  gpu_str = ''
  try:
    if 'gpu' in rdf.GRES:
      num_gpus  = int(rdf.GRES.split(':')[-1])
      gpu_str   = list(num_gpus*gpu_status_symbol['idle'])
      if rdf.gpu_index == rdf.GRES_USED:
        gpu_alloc = int(rdf.GRES_USED.split(':')[-1])
        for ell in range(gpu_alloc):
          gpu_str[ell] = gpu_status_symbol['alloc']
      elif 'IDX' in rdf.GRES_USED:
        for ell in rdf.gpu_index.split(','):
          if '-' in ell:
            m,n = ell.split('-')
            for k in range(int(m),int(n)+1):
              gpu_str[k] = gpu_status_symbol['alloc']
          elif 'N/A' in ell:
            pass
          else:
            gpu_str[int(ell)] = gpu_status_symbol['alloc']
  except Exception as ex:
    print('GPU string parsing exception: ', ex, rdf.GRES_USED)
    gpu_str = ''
  return ''.join(gpu_str)

HOVERTEMPLATE = r"""<extra></extra>
<b>%{customdata[0]}</b>            
<br>
<b>State</b>: %{customdata[1]}    
<br>
<b>Partition</b>: %{customdata[2]}
<br>
<b>Alloc. / Total Cores</b>: %{customdata[3]}/%{customdata[4]}
<br>
<b>Alloc. / Total RAM</b>: %{customdata[5]:,d}/%{customdata[6]:,d} (GiB) 
<br>
<b>Active RAM</b>: %{customdata[7]:,d} (GiB) 
<br>
<b>CPU Load</b>: %{customdata[8]}
<br>
<b>Features</b>: %{customdata[9]}  
%{customdata[10]}
"""
 
AGG_DICT = { k : 'first' for k in COLS }
AGG_DICT['PARTITION'] = ','.join
AGG_DICT.pop('NODELIST',None)

STATE_COLOR_MAP = {
  'idle'        : '#00ff00',
  'idle*'       : '#00ff00',
  'idle-'       : '#00ff00',
  'idle+'       : '#00ff00',
  'idle$'       : '#00ff00',
  'mixed'       : '#b25f00', # mc change to darker orange for better grayscale contrast
  'mixed+'      : '#b25f00',
  'mixed*'      : '#b25f00',
  'mixed$'      : '#b25f00',
  'mixed-'      : '#b25f00',
  'allocated'   : '#ff0000',
  'allocated$'  : '#ff0000',
  'allocated*'  : '#ff0000',
  'allocated-'  : '#ff0000',
  'allocated+'  : '#ff0000',
  'completing'  : '#ffff00',
  'completing*' : '#ffff00',
  'down'        : '#777777',
  'down$'       : '#777777',
  'down*'       : '#777777',
  'down-'       : '#777777',
  'drained'     : '#00aacc',
  'drained$'    : '#00aacc',
  'drained*'    : '#00aacc',
  'drained-'    : '#00aacc',
  'drained+'    : '#00aacc',
  'draining'    : '#00ddff',
  'draining$'   : '#00ddff',
  'draining*'   : '#00ddff',
  'inval'       : '#999900',
  'maint'       : '#ff5f15',
  'maint*'      : '#ff5f15',
  'planned'     : '#ffb300',
  'unknown*'    : '#999999',
  'reboot^'     : '#ffffff',
  'reserved'    : '#990000',
  'reserved$'   : '#990000',
  'reserved*'   : '#990000',
  'reserved-'   : '#990000',
  'reserved+'   : '#990000',
}

STATE_TEXTFONT_COLOR_MAP = {
  'idle'        : '#000000',
  'idle*'       : '#000000',
  'idle-'       : '#000000',
  'idle+'       : '#000000',
  'idle$'       : '#000000',
  'mixed'       : '#ffffff', #MC change to white font
  'mixed$'      : '#ffffff',
  'mixed*'      : '#ffffff',
  'mixed+'      : '#ffffff',
  'mixed-'      : '#ffffff',
  'allocated'   : '#ffffff',
  'allocated$'  : '#ffffff',
  'allocated*'  : '#ffffff',
  'allocated-'  : '#ffffff',
  'allocated+'  : '#ffffff',
  'completing'  : '#000000',
  'completing*' : '#000000',
  'down'        : '#ffffff',
  'down*'       : '#ffffff',
  'down$'       : '#ffffff',
  'down-'       : '#ffffff',
  'drained'     : '#000000',
  'drained$'    : '#000000',
  'drained*'    : '#000000',
  'drained-'    : '#000000',
  'drained+'    : '#000000',
  'draining'    : '#000000',
  'draining$'   : '#000000',
  'draining*'   : '#000000',
  'inval'       : '#ff0000',
  'maint'       : '#000000',
  'maint*'      : '#000000',
  'planned'     : '#000000',
  'unknown*'    : '#ffff00',
  'reboot^'     : '#000000',
  'reserved'    : '#ffffff',
  'reserved$'   : '#ffffff',
  'reserved*'   : '#ffffff',
  'reserved-'   : '#ffffff',
  'reserved+'   : '#ffffff',
}

SCATTER_OPTS = dict(
  x='x',
  y='y',
  color='STATE',
  custom_data=COLS,
  color_discrete_map=STATE_COLOR_MAP,
  text='NODELIST',
  category_orders={'STATE':STATE_COLOR_MAP.keys()},
)

TITLE_DICT = dict(
  text=f'<b>Notchpeak Node Status</b> {now} <br>{stat_str}',
  y=0.990,
  x=0.0,
  xanchor='left',
  yanchor='top',
)

if __ANIM_MODE__:
  TITLE_DICT['text'] = f'<b>Notchpeak Node Status</b> {datafile.split("/")[-1].split(".")[0].split("node-status-")[-1]} <br>{stat_str}'
  

TRACE_OPTS = dict(
  hovertemplate=HOVERTEMPLATE,
  marker_line_width = 2,  
  marker_size       = 64, # MC this controls height of the node  
  marker_symbol     = 'square',  
  textposition      = 'middle center',  
  line_color        = '#000000',
  textfont=dict(family=['monospace'],size=FONTSIZE,color='#000000'),
)

df = pd.read_csv(datafile,delim_whitespace=True,escapechar='\\')
df['SPECIAL']    = ''
df['CPU_LOAD']   = df['CPU_LOAD'].fillna(0)
df['ALLOCMEM']   = df['ALLOCMEM'].fillna(0)/1024
df['FREE_MEM']   = df['FREE_MEM'].fillna(0)/1024
df['MEMORY']     = df['MEMORY']/1024
df['ALLOC_CPUS'] = df.apply(lambda x: int(x['CPUS(A/I/O/T)'].split('/')[0]), axis=1).fillna(0)
df['ACTIVEMEM' ] = df['MEMORY'] - df['FREE_MEM']

df = df[df['NODELIST'].str.match(r'notch\d+')] # KE filter out unwanted nodes

df.loc[df['GRES']=='(null)','GRES_USED'] = ''
df.loc[df['GRES']!='(null)','GRES'] = df.loc[df['GRES']!='(null)','GRES'].str.replace(r'(S:0-1)','',regex=False)

df.loc[df['TIMESTAMP'] != 'Unknown','TIMESTAMP'] = '('+df.loc[df['TIMESTAMP']!='Unknown','TIMESTAMP']+') '
df.loc[df['GRES'] != '(null)','SPECIAL'] = '<br> <b>GPUs</b>: ' \
  + df.loc[df['GRES'] != '(null)','GRES_USED'].str.replace(r'\(IDX.*',' / ',regex=True).str.replace('gpu:','') \
  + df.loc[df['GRES'] != '(null)','GRES'].str.replace(r'gpu:.*:','',regex=True)
df.loc[df['REASON'] != 'none','SPECIAL'] += '<br> <b>Reason</b>: '+df.loc[df['REASON'] != 'none','TIMESTAMP']+df.loc[df['REASON'] != 'none','REASON']

df['gpu_index']  = df['GRES_USED'].str.replace(r'\(S:*',' / ',regex=True).str.replace(r'.*IDX:|\)','',regex=True)
df['gpu_str'] = df.apply(lambda x: get_gpu_str(x),axis=1)

filter = df['NODELIST'].str.contains("dtn")
df = df[~filter]
df = df.groupby('NODELIST').agg(AGG_DICT).reset_index()
L  = len(df)
N  = 15
M  = int(L/N+1)
df['y'] = M-1-df.apply(lambda x: x.name//N,axis=1)
df['x'] = df.apply(lambda x: x.name%N, axis=1)
gdf = df.loc[df['gpu_str']!='',['x','y','gpu_str','STATE']]

fig = px.scatter(df,**SCATTER_OPTS)
fig.layout.xaxis['visible'] = False
fig.layout.yaxis['visible'] = False
fig.layout.paper_bgcolor = '#eeeeee'
fig.layout.plot_bgcolor  = '#eeeeee'
fig.layout.width  = BASE_WIDTH * N # /11) if M > 11 else BASE_WIDTH
fig.layout.height = BASE_DEPTH * M # /11) if N > 11 else BASE_DEPTH
print('len M N w h')
print(len(df), M, N, fig.layout.width, fig.layout.height)
fig.update_traces(**TRACE_OPTS)
pshapes = []
for i,r in gdf.iterrows():
  c = STATE_TEXTFONT_COLOR_MAP[r.STATE]
  # TODO: make more flexible -- this is hard coded for 4 A100s split
  # into 7 MIG slices each (28 total MIG instances).
  if len(r.gpu_str) == 28:
    gpus_alloc = [[],[],[],[]]
    for k,status in enumerate(r.gpu_str):
      if status == gpu_status_symbol['alloc']:
        gpu_num = k//7
        gpu_ind = k%7
        gpus_alloc[gpu_num].append(gpu_ind)
    for k in range(4):
      pdisk,psegs = mig_disk(center=np.r_[r.x-0.32+k*0.21,r.y-0.32], radius=0.095, alloc_mig=gpus_alloc[k], max_mig=7, n=101)
      pshapes.append(dict(type="path",path=pdisk,line_color=c,line=dict(width=1.2)))
      for pseg in psegs:
        pshapes.append(
          dict(type="path",path=pseg,fillcolor=c,line_color=c,line=dict(width=0))
        )
  else:
    fig.add_annotation(
      x=r.x-0.45,
      y=r.y-0.16,
      text=r.gpu_str,
      showarrow=False,
      xanchor='left',
      yanchor='top',
      font=dict(size=FONTSIZE,color=c),
    )
fig.update_layout(
  autosize=True,
# width=500,
# height=500,
  margin=dict(
      l=0,
      r=0,
      b=0,
      t=50,
#     pad=4
  ),
# paper_bgcolor="white",
  xaxis_range= [-0.5,df['x'].values.max()+0.5],
  yaxis_range= [-0.5,df['y'].values.max()+0.5],
  title=TITLE_DICT,
  shapes=pshapes 
)
for scatter in fig.data:
  legendgroup = scatter['legendgroup']
  if legendgroup in STATE_TEXTFONT_COLOR_MAP:
    scatter['textfont']['color'] = STATE_TEXTFONT_COLOR_MAP[legendgroup]
  else:
    if not __ANIM_MODE__:
      with open('crontab.diag.log','a') as fh:
        print(f'[{now}] undefined legendgroup: {legendgroup}', file=fh)
  
if not __ANIM_MODE__: 
  plotly.offline.plot(fig,filename="sol2.html",include_plotlyjs="cdn",auto_open = False)
else:
  fig.write_image(f"anim/{datafile.split('/')[-1].split('.')[0]}.png",scale=2)
