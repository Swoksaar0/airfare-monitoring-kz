"""Render matching editable PlantUML, SVG and report PNG diagrams.

Run: python render_architecture.py --output docs/diagrams
Requires Pillow for PNG output. No network requests or backend execution.
"""
from pathlib import Path
import argparse, html, math
from PIL import Image, ImageDraw, ImageFont

def node(key, kind, rect, lines, planned=False):
    return dict(key=key, kind=kind, rect=rect, lines=lines, planned=planned)

def edge(a,b,pts,label='',pos=None,planned=False,cardinality=False):
    return dict(a=a,b=b,pts=pts,label=label,pos=pos,planned=planned,cardinality=cardinality)

DIAGRAMS = {
 'system-context': dict(title='System context', size=(1800,1100), note='24 October 2026 | Source access and production delivery remain unverified', nodes=[
  node('Traveler','actor',(40,160,420,330),['Traveler','Read observations','Set a threshold']),
  node('Operator','actor',(40,710,420,880),['Operator','Initiate collection','Inspect outcomes']),
  node('System','rectangle',(650,350,1170,720),['Airfare Monitoring KZ','Mobile application and backend','Flutter demo exists','Backend prototype exists','Integration not verified']),
  node('Provider','cloud',(1380,210,1770,430),['Travelpayouts API','External cached-price source','Access / coverage unverified']),
  node('Push','cloud',(1380,740,1770,940),['Push delivery provider','Future external dependency','No delivery implemented'],True),
 ], edges=[
  edge('Traveler','System',[(420,245),(520,245),(520,440),(650,440)],'Read / track',(540,200)),
  edge('Operator','System',[(420,795),(520,795),(520,630),(650,630)],'Start collection',(525,850)),
  edge('System','Provider',[(1170,440),(1270,440),(1270,320),(1380,320)],'Server request / result',(1480,490)),
  edge('System','Push',[(1170,630),(1270,630),(1270,840),(1380,840)],'Future delivery requests',(1480,675),True),
 ]),
 'components': dict(title='Components present in the repository',size=(1800,1320),note='Solid: dependency exists in code | Dashed: experimental API path, integration unverified',nodes=[
  node('Fixture','component',(50,70,530,240),['Demo data','Synthetic history','Persistent local rules']),
  node('Mobile','component',(680,70,1160,240),['Flutter client','mobile-app branch','DEMO_MODE=true by default']),
  node('API','component',(680,400,1160,590),['FastAPI','HTTP routing','Routes / history / alerts','Collect / analytics']),
  node('Collector','component',(50,700,530,900),['Collection service','Provider adapter inside','Fetch / normalize / store','Threshold checks']),
  node('Analytics','component',(1270,700,1750,900),['Analytics','History by route + date','Median / linear baseline']),
  node('Source','cloud',(50,1050,530,1200),['Travelpayouts API','External cached quotes','Live coverage unverified']),
  node('DB','database',(680,1020,1160,1220),['PostgreSQL','SQLAlchemy models','Route / Snapshot / Alert','Deployment unverified']),
 ],edges=[
  edge('Mobile','Fixture',[(680,155),(530,155)],'Demo mode',(600,105)),
  edge('Mobile','API',[(920,240),(920,400)],'HTTP when DEMO_MODE=false',(1195,315),True),
  edge('API','Collector',[(680,470),(290,470),(290,700)],'POST /collect',(380,425)),
  edge('API','Analytics',[(1160,470),(1510,470),(1510,700)],'GET /analytics',(1420,425)),
  edge('API','DB',[(920,590),(920,1020)],'Routes / rules',(1060,945)),
  edge('Collector','Source',[(290,900),(290,1050)],'Request',(215,980)),
  edge('Collector','DB',[(530,800),(610,800),(610,1120),(680,1120)],'Write',(650,970)),
  edge('Analytics','DB',[(1270,800),(1220,800),(1220,1120),(1160,1120)],'Read history',(1370,990)),
 ]),
 'entities': dict(title='Existing ORM entities and relationships',size=(1800,1220),note='Existing schema only | 1 to 0..* | Source / run / delivery tables are proposed separately',nodes=[
  node('Route','entity',(610,60,1190,375),['Route / routes','PK id','origin_iata / destination_iata','origin_city / destination_city','is_active','UNIQUE(origin_iata, destination_iata)']),
  node('Snapshot','entity',(40,585,865,1140),['PriceSnapshot / price_snapshots','PK id | FK route_id -> routes.id','departure_date: Date','price_kzt: Float','airline_code / flight_number: nullable','transfers: Integer','source_found_at: required DateTime','collected_at: required DateTime','is_fresh / days_before_departure']),
  node('Alert','entity',(935,585,1760,1140),['PriceAlert / price_alerts','PK id | FK route_id -> routes.id','device_token: required String','departure_date: Date','threshold_kzt: Float','is_active: Boolean','last_notified_price_kzt: nullable','last_notified_at: nullable','Rule state is not delivery evidence']),
 ],edges=[
  edge('Route','Snapshot',[(745,375),(745,470),(450,470),(450,585)],'1 to 0..* snapshots',(435,430),cardinality=True),
  edge('Route','Alert',[(1055,375),(1055,470),(1350,470),(1350,585)],'1 to 0..* alerts',(1365,430),cardinality=True),
 ]),
 'data-flow': dict(title='Target data flow after data trust corrections',size=(1800,1500),note='Proposed behavior | Scheduler, outcome records and push delivery are not implemented',nodes=[
  node('Target','component',(430,60,1160,200),['1  Select collection target','Operator or future bounded scheduler','Route / departure / passengers / currency'],True),
  node('Fetch','component',(430,300,1160,440),['2  Request source data','Server-side provider adapter','API credentials remain on the server'],True),
  node('Validate','component',(430,540,1160,680),['3  Validate response and identity','Check route / date / currency / amount','Unknown metadata remains unknown'],True),
  node('Outcomes','component',(1310,520,1770,700),['No valid quote','Record run outcome','Do not write a price','No invented values'],True),
  node('Store','database',(430,780,1160,920),['4  Persist accepted observations','Source / timestamps / cache or demo status','Commit accepted observations first'],True),
  node('Read','component',(430,1020,1160,1160),['5  Read a comparable history','API and analytics by route / departure','Return timestamps and data kind'],True),
  node('Delivery','component',(1310,815,1770,1025),['Future delivery','Check real observation','Attempt push','Record outcome'],True),
  node('Client','component',(430,1260,1160,1420),['6  Flutter presentation','Show history / assessment / timestamps','Display delivery status honestly'],True),
 ],edges=[
  edge('Target','Fetch',[(790,200),(790,300)],'Bounded work item',(1010,250),True),
  edge('Fetch','Validate',[(790,440),(790,540)],'Response or failure',(1000,490),True),
  edge('Validate','Outcomes',[(1160,610),(1310,610)],'Not accepted',(1235,475),True),
  edge('Validate','Store',[(790,680),(790,780)],'Accepted quote',(990,730),True),
  edge('Store','Read',[(790,920),(790,1020)],'Stored history',(970,970),True),
  edge('Read','Client',[(790,1160),(790,1260)],'HTTP JSON',(965,1210),True),
  edge('Store','Delivery',[(1160,850),(1310,850)],'After commit',(1235,740),True),
  edge('Delivery','Client',[(1540,1025),(1540,1320),(1160,1320)],'Device notification',(1530,1190),True),
 ])
}

def get_font(size,bold=False):
    names=[Path('C:/Windows/Fonts/arialbd.ttf' if bold else 'C:/Windows/Fonts/arial.ttf'),Path('/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf' if bold else '/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf')]
    for p in names:
        if p.exists(): return ImageFont.truetype(str(p),size)
    return ImageFont.load_default()

def render(name,spec,out):
    width,height=spec['size']
    im=Image.new('RGB',(width,height),'white');d=ImageDraw.Draw(im)
    parts=[f'<svg xmlns="http://www.w3.org/2000/svg" width="{width}" height="{height}" viewBox="0 0 {width} {height}" role="img" aria-labelledby="title desc">',f'<title id="title">{html.escape(spec["title"])}</title>',f'<desc id="desc">{html.escape(spec["note"])}</desc>','<rect width="100%" height="100%" fill="white"/>']
    def text(x,y,value,size=28,bold=False):
        d.text((x,y),value,font=get_font(size,bold),fill='#202020',anchor='mm')
        parts.append(f'<text x="{x}" y="{y}" text-anchor="middle" dominant-baseline="central" font-family="Arial, sans-serif" font-size="{size}" font-weight="{700 if bold else 400}" fill="#202020">{html.escape(value)}</text>')
    # Connections are drawn behind the nodes; labels use white backgrounds.
    for e in spec['edges']:
        pts=e['pts'];planned=e['planned']
        if planned:
            for a,b in zip(pts,pts[1:]):
                dx,dy=b[0]-a[0],b[1]-a[1];length=math.hypot(dx,dy)
                for k in range(0,int(length),20):
                    t0=k/length;t1=min(k+12,length)/length
                    d.line([(a[0]+dx*t0,a[1]+dy*t0),(a[0]+dx*t1,a[1]+dy*t1)],fill='#555555',width=3)
        else:d.line(pts,fill='#555555',width=3)
        b=pts[-1];a=pts[-2];ang=math.atan2(b[1]-a[1],b[0]-a[0]);tip=[b,(b[0]-17*math.cos(ang-.5),b[1]-17*math.sin(ang-.5)),(b[0]-17*math.cos(ang+.5),b[1]-17*math.sin(ang+.5))]
        d.polygon(tip,fill='#555555')
        points=' '.join(f'{x},{y}' for x,y in pts);dash=' stroke-dasharray="12 8"' if planned else ''
        parts.append(f'<polyline points="{points}" fill="none" stroke="#555555" stroke-width="3"{dash}/>')
        parts.append('<polygon points="'+' '.join(f'{x},{y}' for x,y in tip)+'" fill="#555555"/>')
    for n in spec['nodes']:
        x0,y0,x1,y1=n['rect'];fill='#F5F5F5' if n['planned'] else '#EFF3F8'
        d.rounded_rectangle(n['rect'],radius=12,fill=fill,outline='#444444',width=3)
        parts.append(f'<rect x="{x0}" y="{y0}" width="{x1-x0}" height="{y1-y0}" rx="12" fill="{fill}" stroke="#444444" stroke-width="3"/>')
        lines=n['lines'];step=43 if len(lines)>5 else 40;top=(y0+y1)/2-(len(lines)-1)*step/2
        for i,line in enumerate(lines):
            size=36 if i==0 else 32
            # Reduce only unusually long field/constraint lines, preserving readable labels.
            while get_font(size,i==0).getlength(line)>x1-x0-32:size-=1
            text((x0+x1)/2,top+i*step,line,size,i==0)
    for e in spec['edges']:
        if e['label']:
            x,y=e['pos'];font=get_font(25);tw=font.getlength(e['label'])
            d.rectangle((x-tw/2-7,y-18,x+tw/2+7,y+18),fill='white')
            parts.append(f'<rect x="{x-tw/2-7}" y="{y-18}" width="{tw+14}" height="36" fill="white"/>')
            text(x,y,e['label'],25)
    text(width/2,height-22,spec['note'],22)
    parts.append('</svg>')
    (out/(name+'.svg')).write_text('\n'.join(parts),encoding='utf-8')
    im.save(out/(name+'.png'))
    puml=['@startuml',f'title {spec["title"]}','top to bottom direction','skinparam shadowing false','skinparam defaultFontName Arial','skinparam componentStyle rectangle']
    for n in spec['nodes']:
        label='\\n'.join(n['lines']).replace('"','\\"')
        puml.append(f'{n["kind"]} "{label}" as {n["key"]}'+(' #F5F5F5' if n['planned'] else ' #EFF3F8'))
    for e in spec['edges']:
        arrow='..>' if e['planned'] else '-->'
        if e['cardinality']:puml.append(f'{e["a"]} "1" -- "0..*" {e["b"]}')
        else:puml.append(f'{e["a"]} {arrow} {e["b"]} : {e["label"]}')
    puml+=['legend bottom',spec['note'],'endlegend','@enduml']
    (out/(name+'.puml')).write_text('\n'.join(puml)+'\n',encoding='utf-8')

def render_all(out):
    out=Path(out);out.mkdir(parents=True,exist_ok=True)
    for name,spec in DIAGRAMS.items():render(name,spec,out)

if __name__=='__main__':
    parser=argparse.ArgumentParser();parser.add_argument('--output',type=Path,default=Path(__file__).resolve().parent)
    args=parser.parse_args();render_all(args.output);print(f'Rendered {len(DIAGRAMS)} diagrams to {args.output}')


