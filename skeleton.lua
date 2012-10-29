-- skeleton class

skeleton = SECS_class:new()

function skeleton:new(...)
   local _o = {}
   _o.name=""
   _o.bones={}
   _o.draworder={}
   _o.animations={}
   _o.initialized=false
   _o.play=false
   _o.nextanimation=nil
   setmetatable(_o, self)
   self.__index = self
   _o:init(...)
   return _o
end

function skeleton:init(pfile)
  if pfile then
    self:load_from_json(pfile)
  end
end

function skeleton:update(dt)
  if not self.initialized then
    arrange_bones(self)
  end
  local cos,sin,interpolate = math.cos,math.sin,interpolate
  local _r,_fromx,_fromy,_tox,_toy
  for i,v in pairs(self.bones) do
    if v.curranim then
        if self.play == true then
            v.currtime=v.currtime+dt*8
            if v.currtime > v.curranim.frametime then
              v.currtime = v.currtime - v.curranim.frametime
              v.fromframe.r=v.r
              v.fromframe.x=v.x
              v.fromframe.y=v.y
              v.currframe = v.currframe + 1
              if v.currframe > v.curranim.frames then
                if v.curranim.loop==true then
                  v.currframe=1
                elseif v.curranim.toanim and v.curranim.toanim ~="" then
                  if string.sub(v.curranim.toanim,1,1)=="*" and self.nextanimation then
                    self:set_animation(self.nextanimation[1],self.nextanimation[2],self.nextanimation[3],self.nextanimation[4],self.nextanimation[5],v.curranim.name)
                  elseif string.sub(v.curranim.toanim,1,1)=="[" then
                    local _boneid = string.sub(v.curranim.toanim,2,-2)
                    for ii,vv in pairs(self.bones) do
                      if vv.id == _boneid then
                        v.curranim = v.anim[vv.curranim.name]
                        v.currframe=vv.currframe
                        if v.currframe > v.curranim.frames then
                          v.currframe=1
                        end
                        break
                      end
                    end
                  else
                    v.curranim = v.anim[v.curranim.toanim]
                    v.currframe=1
                  end
                end
              end
              v.toframe.r=v.curranim[v.currframe].r
              v.toframe.x=v.curranim[v.currframe].x
              v.toframe.y=v.curranim[v.currframe].y
            end  
            --print("--"..self.name.." "..i.." "..v.id)
            --print(v.fromframe.r)
            --print(v.toframe.r)
            --print(v.currtime)
            
            v.r = interpolate(v.fromframe.r,v.toframe.r,v.currtime)
            v.x = interpolate(v.fromframe.x,v.toframe.x,v.currtime)
            v.y = interpolate(v.fromframe.y,v.toframe.y,v.currtime)
        else
        --print(self.name.." "..v.id..":"..v.currframe)
        --print(DataDumper(v.anim.idle))
        --print(DataDumper(v.curranim))
            v.r = v.curranim[v.currframe].r
            v.x = v.curranim[v.currframe].x
            v.y = v.curranim[v.currframe].y
        end
        if v.parentid == nil then
          _fromx,_fromy,_r=v.x,v.y,v.r
        else
          if v.independent then
            _r=v.r
          else
            _r=self.bones[v.parentindex].cr+v.r
          end
          if v.x ==0 and v.y==0 then
            _fromx,_fromy=self.bones[v.parentindex].dx,self.bones[v.parentindex].dy
          else
            _fromx,_fromy=self.bones[v.parentindex].dx+v.x,self.bones[v.parentindex].dy+v.y
          end
        end
        if v.s==0 then
          _tox,_toy=_fromx,_fromy
        else
          _tox,_toy=_fromx+cos(_r)*v.s,_fromy+sin(_r)*v.s
        end
        v.cr,v.cx,v.cy,v.dx,v.dy=_r,_fromx,_fromy,_tox,_toy
    else
        if v.parentid == nil then
          _fromx,_fromy,_r=v.x,v.y,v.r
        else
          if v.independent then
            _r=v.r
          else
            _r=self.bones[v.parentindex].cr+v.r
          end
          if v.x ==0 and v.y==0 then
            _fromx,_fromy=self.bones[v.parentindex].dx,self.bones[v.parentindex].dy
          else
            _fromx,_fromy=self.bones[v.parentindex].dx+v.x,self.bones[v.parentindex].dy+v.y
          end
        end
        if v.s==0 then
          _tox,_toy=_fromx,_fromy
        else
          _tox,_toy=_fromx+cos(_r)*v.s,_fromy+sin(_r)*v.s
        end
        v.cr,v.cx,v.cy,v.dx,v.dy=_r,_fromx,_fromy,_tox,_toy
    end
  end
end

function skeleton:draw(physics,graphics)
end

function skeleton:add_bone(pid,pname,pparentid,px,py,pr,ps,pindependent,pimg,pz)
  local _level = 1
  if pparentid~=nil then
    for i,v in ipairs(self.bones) do
      if v.id==pparentid then
        _level = v.level + 1
        break
      end
    end
  end
  local bone={id=pid,name=pname,level=_level,parentid=pparentid,x=px,y=py,r=pr,s=ps,cr=pr,cx=px,cy=py,dx=px,dy=py,independent=pindependent,img=pimg,z=pz}
  bone.anim = {}
  bone.anim.idle = {}
  bone.anim.idle[1] = {}
  bone.anim.idle[1].r = bone.r
  bone.anim.idle[1].x = bone.x
  bone.anim.idle[1].y = bone.y
  bone.anim.idle.frames=1
  bone.anim.idle.loop=true
  bone.anim.idle.frametime=1  
  bone.curranim=nil
  bone.currframe=1
  bone.currtime=0
  bone.fromframe={}
  bone.fromframe.r=bone.r
  bone.fromframe.x=bone.x
  bone.fromframe.y=bone.y
  bone.toframe={}
  bone.toframe.r=bone.r
  bone.toframe.x=bone.x
  bone.toframe.y=bone.y
  table.insert(self.bones,bone)
  self.initialized=false
end

function skeleton:arrange_bones()
  table.sort(self.bones, function(a,b) 
    return a.level<b.level or (a.level==b.level and a.id<b.id) end)
  self.draworder={}
  self.animations={}
  --print("inizio")
  local _bones=0
  for i,v in ipairs(self.bones) do
    _bones = _bones + 1
    if v.parentid==nil then
      v.parentindex=nil
    else
      for ii,vv in ipairs(self.bones) do
        if vv.id == v.parentid then
          v.parentindex=ii
          break
        end
      end
    end
    --print (v.parentindex)
    table.insert(self.draworder,{index=i,z=v.z})
    --print(i)
    --print(v.z)
     for ii,vv in pairs(v.anim) do
       vv.name=ii
       if self.animations[ii]==nil then
         self.animations[ii]={anim=ii,numbones=1,frames=vv.frames,frametime=vv.frametime}
       else
         self.animations[ii].numbones=self.animations[ii].numbones+1
       end
     end
  end
  for i,v in pairs(self.animations) do
    if v.numbones==_bones then
      v.fullbody=true
    else
      v.fullbody=false
    end
  end
  --print(DataDumper(self.animations))
  table.sort(self.draworder, function(a,b) 
    return a.z<b.z end)
  self.initialized=true
end

function skeleton:set_animation(panim,poverride,pframe,pplay,ptweenfromlastframe,poverrideanim)
  --print("set")
  --print(poverrideanim)
  self.play=pplay
  local _animation_set=false
  for i,v in ipairs(self.bones) do
    if panim == nil then
      v.curranim=nil
      v.currframe=pframe
      v.currtime=0
      v.fromframe={}
      v.fromframe.r=v.r
      v.fromframe.x=v.x
      v.fromframe.y=v.y
      v.toframe={}
      v.toframe.r=v.r
      v.toframe.x=v.x
      v.toframe.y=v.y
      _animation_set=true
    elseif v.anim[panim] then
      local _curranimname = ""
      if v.curranim then
        _curranimname=v.curranim.name
      end
      --print("cur:".._curranimname)
      --print(poverrideanim)
      if poverride==true or string.sub(_curranimname,1,1)~="!" or _curranimname==poverrideanim then
        _animation_set=true
        v.curranim=v.anim[panim]
        v.currframe=pframe
        v.currtime=0
        v.fromframe={}
        if ptweenfromlastframe then
          v.fromframe.r=v.r
          v.fromframe.x=v.x
          v.fromframe.y=v.y
        else
          v.fromframe.r=v.curranim[v.currframe].r
          v.fromframe.x=v.curranim[v.currframe].x
          v.fromframe.y=v.curranim[v.currframe].y
          if pplay and v.currframe<v.curranim.frames then
            v.currframe=v.currframe+1
          end
        end
        v.toframe={}
        --print(DataDumper(v))
        --print(v.id)
        --print(v.currframe)
        --print(DataDumper(v.curranim))
        --print(DataDumper(v.anim))
        v.toframe.r=v.curranim[v.currframe].r
        v.toframe.x=v.curranim[v.currframe].x
        v.toframe.y=v.curranim[v.currframe].y
      end
    end
  end
  if _animation_set==false then
    self.nextanimation = {panim,poverride,pframe,pplay,ptweenfromlastframe}
  --else
    --self.nextanimation = nil
  end
end

function skeleton:load_from_json(pfile)
    local jsontable = love.filesystem.read(pfile)
    _table = json.decode(jsontable)
    self.bones = _table.bones
    --print ("prefix")
    --fix animation indexed by string   
    for i,v in pairs(self.bones) do
      --print ("prefix "..i)
      for ii,vv in pairs(v.anim) do
        --print ("prefix "..i.." "..ii)
        if vv[1]==nil and vv["1"]~=nil then
          --print ("fix "..i.." "..ii)
          local newanim = {}
          for iii,vvv in pairs(vv) do
            if tonumber(iii) then
              newanim[tonumber(iii)]=vvv
            else
              newanim[iii]=vvv
            end
          end  
          v.anim[ii] = newanim
        end
      end
    end
    self:arrange_bones()
end

function skeleton:getBoneById(pid)
  for i,v in ipairs(self.bones) do
    if v.id == pid then
      return v
    end
  end
  return nil
end

function interpolate(from,to,timing)
  if timing <= 0 or from==to then
    return from
  elseif timing >= 1 then
    return to
  end
  return from+(to-from)*timing
end

