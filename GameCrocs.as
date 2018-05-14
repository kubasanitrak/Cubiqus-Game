package
{
	import flash.geom.*;

	import nape.geom.Vec2;
	import nape.phys.*;
	import nape.shape.*;
	import nape.space.Space;
	import nape.util.BitmapDebug;
	import nape.callbacks.*;


	import starling.core.Starling;
	import starling.display.*;
	import starling.events.*;
	import starling.textures.Texture;
	// import starling.utils.AssetManager;

	import com.greensock.*;
	import com.greensock.easing.*;
	import com.greensock.events.LoaderEvent;
	import com.greensock.loading.*;

	import Enemies.*;

	public class GameCrocs extends Scene
	{

		public static const HERO_SMASHED:String = "HeroSmashed";
		public static const HERO_WINS:String = "HeroWins";

		public static const PHASE_IDLE:String = "phaseIdle";
		public static const PHASE_RESUMED:String = "phaseResume";
		public static const PHASE_PAUSED:String = "phasePause";
		public static const PHASE_PLAYING:String = "phasePlaying";
		public static const PHASE_SMASHED:String = "phaseSmashed";

		private var _phase:String;
		private var _screenW:Number;
		private var _screenH:Number;

		private var _tileWH:int = 30;

// NAPE PHYSICS VARS
		private var _space:Space;
		private var myDebugger:BitmapDebug;
		private var ballCollisionType:CbType=new CbType();

		private var ballHitsLEFTWall:InteractionListener;
		private var wallLEFTCType:CbType=new CbType();

		private var ballHitsTOPWall:InteractionListener;
		private var wallTOPCType:CbType=new CbType();

		private var ballHitsRIGHTWall:InteractionListener;
		private var wallRIGHTCType:CbType=new CbType();

		private var ballHitsBOTTOMWall:InteractionListener;
		private var wallBOTTOMCType:CbType=new CbType();

		private var wallBodyL:Body;
		private var wallBodyT:Body;
		private var wallBodyR:Body;
		private var wallBodyB:Body;

		private var _boostUp:Boolean;

		private var _swipeDir:String;
		private var _applyX:Number;
		private var _applyY:Number;
		private var _distMin:int = 30; //MINIMUM AMOUNT TO SWIPE
		private var _forceConst:int = 800; // MINIMUM FORCE TO ACCELERATE IN X AXIS
		private var _forceMax:int = 2500; // MAXIMUM FORCE TO ACCELERATE IN X OR Y AXIS

		private var _distX:Number;
		private var _distY:Number;

		private var _hero:Hero;
// ENEMY VARS
		private var croc1:Crocodile;
		private var croc2:Crocodile;
		private var enemiesArray:Array;
		// private var enemiesArray:Array = super._enemies;
		private var _crocsCount:int = 0;
		private var _halfScreenW:int;
		private var _halfScreenH:int;

		private var _wallThin:int = 100;

		private var _minX:int = 10;
		private var _minY:int = 9;
		private var _maxX:int = 8;
		private var _maxY:int = 4;
		private var _gridX:int;
		private var _gridY:int;

// SOUND HANDLING	
		private var _mainSongLoader:MP3Loader;

		// public function GameCrocs(width:Number, height:Number)
		override public function init(width:Number, height:Number):void
		{
			_phase = PHASE_IDLE;
			_screenW = width;
			_screenH = height;

			_halfScreenW = Math.ceil(_screenW * 0.5);
			_halfScreenH = Math.ceil(_screenH * 0.85);

// trace("GameCrocs screen dimensions: " + _screenW + " x " + _screenH);

			
			addEventListener(Crocodile.HERO_SMASH, heroWhacked);
			addEventListener(Crocodile.HERO_WIN, watchForWinner);

			initSpace();
			addBounds();
			addEnemies();
			addHero();

			addEventListener("heroDoneAnim", heroWon);

			loadMainSong();
		}

		override public function resizeTo(width:Number, height:Number, multiply:int=1):void
		{
			super.init(width, height);
				
			_screenW = width;
			_screenH = height;

			_halfScreenW = Math.ceil(_screenW * 0.5);
			_halfScreenH = Math.ceil(_screenH * 0.85);

			reset();
		}

		private function heroWon():void
		{
trace("Hero won noticed in GameCrocs Class");
		}

		private function constantUpdate(e:starling.events.Event=null):void
		{
			_space.step(1 / 60);
			/*/
			myDebugger.clear();
			myDebugger.draw(_space);
			myDebugger.flush();
			_space.liveBodies.foreach(updateGraphic);
			/*/
			_space.liveBodies.foreach(updateGraphic);
			//*/
		}

		private function updateGraphic(obj:Body):void
		{
			var graphic:starling.display.DisplayObject = obj.userData.graphic as starling.display.DisplayObject;
			graphic.x = obj.position.x;
			graphic.y = obj.position.y;
			graphic.rotation = obj.rotation;
		}

		// setup methods


		private function initSpace():void
		{
			// var worldGravity:Vec2 = Vec2.weak(0, 1800);
			// var worldGravity:Vec2 = Vec2.weak(0, 500);
			var worldGravity:Vec2 = Vec2.weak(0, 200);

			if(_space) 
			{
				while (! _space.bodies.empty()) {
					 _space.bodies.clear();
				}
				_space.clear();
				_space = null;
			}
			_space = new Space(worldGravity);
// trace( _space.bodies.length);

			// myDebugger = new BitmapDebug(_screenW, _screenH, 0x000000);
			// OR BETTER:
			// myDebugger = new BitmapDebug(_screenW, _screenH, 0x000000, true); // TRANSPARENT DEBUGGER BGR TO SEE BITMAP ASSETS

			// Starling.current.nativeOverlay.addChild(myDebugger.display);
		}

		private function addBounds():void
		{
// trace("adding Bounds");
			if (!wallBodyL) wallBodyL = new Body(BodyType.STATIC);
			if (!wallBodyT) wallBodyT = new Body(BodyType.STATIC);
			if (!wallBodyR) wallBodyR = new Body(BodyType.STATIC);
			if (!wallBodyB) wallBodyB = new Body(BodyType.STATIC);

			wallBodyL.shapes.add(new Polygon(Polygon.rect(-_wallThin, 0, _wallThin, _screenH) ) ); 
			wallBodyL.space = _space;
			wallBodyL.cbTypes.add(wallLEFTCType);

			wallBodyT.shapes.add(new Polygon(Polygon.rect(0, -_wallThin, _screenW, _wallThin) )  ); 
			wallBodyT.space = _space;
			wallBodyT.cbTypes.add(wallTOPCType);

			wallBodyR.shapes.add(new Polygon(Polygon.rect(_screenW, 0, _wallThin, _screenH) )  ); 
			wallBodyR.space = _space;
			wallBodyR.cbTypes.add(wallRIGHTCType);
			
			wallBodyB.shapes.add(new Polygon(Polygon.rect(0, _screenH, _screenW, _wallThin) ) ); 
			wallBodyB.space = _space;
			wallBodyB.cbTypes.add(wallBOTTOMCType);

			/*
			var wallBody:Body = new Body(BodyType.STATIC);
			var polygonWL:Polygon=new Polygon(Polygon.rect(-_wallThin, 0, _wallThin, _screenH) );
			polygonWL.material.elasticity=0.5;
			polygonWL.material.density=1;
			polygonWL.material.staticFriction=0;
			wallBody.shapes.add(polygonWL);
			wallBody.space = _space;
			*/

			ballHitsLEFTWall=new InteractionListener(CbEvent.BEGIN, InteractionType.COLLISION, wallLEFTCType, ballCollisionType, wallHITleft);
			_space.listeners.add(ballHitsLEFTWall);

			ballHitsTOPWall=new InteractionListener(CbEvent.BEGIN, InteractionType.COLLISION, wallTOPCType, ballCollisionType, wallHITtop);
			_space.listeners.add(ballHitsTOPWall);

			ballHitsRIGHTWall=new InteractionListener(CbEvent.BEGIN, InteractionType.COLLISION, wallRIGHTCType, ballCollisionType, wallHITright);
			_space.listeners.add(ballHitsRIGHTWall);

			ballHitsBOTTOMWall=new InteractionListener(CbEvent.BEGIN, InteractionType.COLLISION, wallBOTTOMCType, ballCollisionType, wallHITbottom);
			_space.listeners.add(ballHitsBOTTOMWall);
		}

		private function addEnemies():void
		{
// trace("adding Enemies");
			
			_gridX = Math.round(_screenW / _tileWH);
			_gridY = Math.round(_screenH / _tileWH);
			
			var croc1X:int = Math.round(_gridX * 0.4);
			croc1X = _tileWH * ((croc1X < _minX) ? _minX : croc1X);
			var croc2X:int = Math.round(_gridX - ( _gridX * 0.7));
			croc2X = _tileWH * (_gridX - ((croc2X > _maxX) ? _maxX : croc2X)) ;

			var croc1Y:int = Math.round(_gridY - ( _gridY * 0.8));
			croc1Y = _tileWH * (_gridY - ((croc1Y > _maxY) ? _maxY : croc1Y) );
			var croc2Y:int = Math.round( _gridY  *  0.4);
			croc2Y =  _tileWH * ((croc1Y < _minY) ? _minY: croc2Y );

			croc1 = new Crocodile(_space, ballCollisionType, croc1X, croc1Y);
			addChild(croc1);

			croc2 = new Crocodile(_space, ballCollisionType, croc2X, croc2Y, 2);
			addChild(croc2);

			enemiesArray = super.enemies as Array;
			enemiesArray = new Array(croc1, croc2);
		}



		private function addHero():void
		{
// trace("adding Hero");
			if(!_hero)
			{
				_hero = new Hero(_space, ballCollisionType, _screenW, _screenH);
				addChild(_hero);
			}
				
			resetHero();
		}

		private function heroWins():void
		{
			// dispatchEventWith(HERO_WINS, true);
		}

		


		// game controls

		override public function start():void
		{
			_phase = PHASE_PLAYING;
			addEventListener(Event.ENTER_FRAME, constantUpdate);

			if(!_hero) return;
			_hero.init();
			
			initEnemies();

			_mainSongLoader.gotoSoundTime(0, false);
			fadeSound(1);

// trace("GAMECROCS START FIRED");
		}
		override public function pause(pause:Boolean = false):void
		{
			
			if (pause && _phase == PHASE_PLAYING)
			{
				_phase = PHASE_PAUSED;
				removeEventListener(Event.ENTER_FRAME, constantUpdate);
				croc1.toggleCustomJuggler(false);
				croc2.toggleCustomJuggler(false);
				
				//PAUSE SOUND
				fadeSound(0);
				return;
// trace("GAMECROCS PAUSED");
			}
			if (!pause && _phase == PHASE_PAUSED)
			{
				_phase = PHASE_PLAYING;
				addEventListener(Event.ENTER_FRAME, constantUpdate);
				initEnemies();
				resetHero();
				
				//PLAY SOUND
				_mainSongLoader.gotoSoundTime(0, false);
				fadeSound(1);
				return;
// trace("GAMECROCS RESUMED");
			}
			if (!pause && _phase == PHASE_PLAYING)
			{
				_phase = PHASE_IDLE;
// trace("GAMECROCS UN-PAUSED");
			}
		}

		private function initEnemies():void
		{
			if(!croc1 || !croc2) return;
			croc1.crocStartLookin();
			croc2.crocStartLookin();
		}

		override public function reset():void
		{
			_phase = PHASE_IDLE;
			

			_crocsCount = 0;
			_space.clear();

			if(_space) {

				while (! _space.bodies.empty()) {
					 _space.bodies.clear();
				}
			}
			
			disposeCrocs();
			disposeBounds();

			disposeSounds();
			// REDRAW DYNBODIES => PLAY AGAIN		
			
			addHero();
		}

		// helper methods

		private function resetHero():void
		{
// trace("reseting hero");
			if(_hero.imgVisible) _hero.resetHeroImg(_screenW, _screenH);
			// _hero.resetHeroImg(_screenW, _screenH);
		}

		private function disposeBounds():void
		{
			if(wallBodyL)
			{
				// wallBodyL.removeFromParent(true);
				wallBodyL = null;
			}
			if(wallBodyT)
			{
				// wallBodyT.removeFromParent(true);
				wallBodyT = null;
			}
			if(wallBodyR) {
				// wallBodyR.removeFromParent(true);
				wallBodyR = null;
			}
			if(wallBodyB) {
				// wallBodyB.removeFromParent(true);
				wallBodyB = null;
			}
			// _space.bodies.clear();
			addBounds();
		}
		private function disposeCrocs():void
		{
			if(croc1)
			{
				croc1.selfDispose();
				croc1.removeFromParent(true);
				croc1 = null;
			}
			if(croc2)
			{
				croc2.selfDispose();
				croc2.removeFromParent(true);
				croc2 = null;
			}
			addEnemies();
		}
		private function disposeSounds():void
		{
			if(_mainSongLoader)
			{
				_mainSongLoader.unload();
				_mainSongLoader.dispose(true);
			}
		}

		// private function watchForWinner():void
		private function watchForWinner(event:Event):void
		{
			++ _crocsCount;
// trace(_crocsCount);

			if(_crocsCount == enemiesArray.length)
			{
trace("YOU WON");
_phase = PHASE_IDLE;
_mainSongLoader.gotoSoundTime(0, false);
				fadeSound(0);
				removeEventListener(Crocodile.HERO_SMASH, watchForWinner);

				_space.clear();
				_hero.playWinAnim();
			// TODO PLAY WIN SOUND
				return;
			}
		}

		override public function boostHeroUp(swipeDirection:String, distanceX:Number, distanceY:Number, boostParam:Boolean=false):void
		{
// trace("boosting heroUp:"
// 	+ "\nswipeDirection: " + swipeDirection
// 	+ "\ndistX: " + distanceX
// 	+ "\ndistY: " + distanceY
// 	+ "\nbol: " + boostParam
// 	);

			_boostUp = boostParam;
			if(!_boostUp) return;

			_swipeDir = swipeDirection;
			_distX = distanceX;
			 _distY = distanceY;
			
			_applyX = Math.round(_distX / _distY * _forceConst);
			_applyY = Math.round(_distY / _distX * _forceConst);

			if(_applyX > _forceMax) _applyX = _forceMax;
			if(_applyY > _forceMax) _applyY = _forceMax;

// trace("impulseX: " + _applyX + "\n" + "impulseY: " + _applyY);

			if(_swipeDir == "TOPRIGHT")
			{
				_applyX = Math.abs(_applyX);
				_applyY = - Math.abs(_applyY);
			}
			if(_swipeDir == "TOPLEFT")
			{
				_applyX = - Math.abs(_applyX);
				_applyY = - Math.abs(_applyY);
			}
			if(_swipeDir == "BOTTOMRIGHT")
			{
				_applyX = Math.abs(_applyX);
				_applyY = Math.abs(_applyY);
			}
			if(_swipeDir == "BOTTOMLEFT")
			{
				_applyX = - Math.abs(_applyX);
				_applyY = Math.abs(_applyY);
			}

			if(_hero) _hero.setNewVelocity(_applyX, _applyY); // APPLY FORCE VECTOR TO ACCELERATE HERO
			_boostUp = false;
		}

		private function heroWhacked(event:Event,  param:Object=null):void
		{
// trace("heroWhacked received");
			_hero.setLost();

			fadeSound(0);
			// TODO PLAY LOOSE SOUND

_phase = PHASE_IDLE;

			if(param=="ready-to-reset")
			{
				_phase = HERO_SMASHED;
// trace("/ / / / /\npassed string param\n/ / / / / ");
			return;
			}
			//PLAY WIN AND CRY CROC ANIMS
			var winN:int;
			var cryN:int;

// trace("/ / / / /\npassed int param\n" + param + "\n/ / / / / ");

			switch(param)
			{
				case 1:
					winN = 0;
					cryN = 1;
					break;

				case 2:
					winN = 1;
					cryN = 0;
					break;
			}

			TweenLite.delayedCall(1, function() {
					enemiesArray[int(cryN)].shutCrocEye();
					enemiesArray[int(winN)].playWinAnim();
				});
		}


		// time-related methods

		private function wallHITleft(collision:InteractionCallback):void
		{
			trace("hit wall: LEFT");
			// TODO PLAY SOUND
		}
		private function wallHITtop(collision:InteractionCallback):void
		{
			trace("hit wall: TOP");
			// TODO PLAY SOUND
		}
		private function wallHITright(collision:InteractionCallback):void
		{
			trace("hit wall: RIGHT");
			// TODO PLAY SOUND
		}
		private function wallHITbottom(collision:InteractionCallback):void
		{
			trace("hit wall: BOTTOM");
			// TODO PLAY SOUND
		}

		// SOUND RELATED METHODS
		private function loadMainSong():void
		{
			_mainSongLoader = new MP3Loader("assets/sounds/apalachian-steel-guitar.mp3", {name:"mainSong", autoPlay: false, repeat: -1, onComplete: MainSongLoaded} );
			_mainSongLoader.load();
		}
		private function MainSongLoaded(e:LoaderEvent):void {
			//trace(_mainSongLoader + " loaded"); 
		}

		private function fadeSound(param:int):void
		{
			if(param > 0)
			{
				_mainSongLoader.playSound();
				trace("playing sound");
			}
			TweenMax.to(_mainSongLoader, 1, {volume: int(param), onComplete: fadeOutDone, onCompleteParams: [param]} );
		}

		private function fadeOutDone(param:int):void
		{
			if(param <= 0)
			{
				_mainSongLoader.pauseSound();
				trace("pausing sound");
			}
		}


		// properties
		override public function get phase():String { return _phase; }

		override public function get enemies():Array { 
			return enemiesArray; 
		}
	}
}
