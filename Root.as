package
{
	import flash.geom.*;
	import flash.net.SharedObject;

	import starling.core.Starling;
	import starling.display.*;
	import starling.events.*;
	import starling.animation.*;
	import starling.utils.AssetManager;
	import starling.filters.*;

	import com.greensock.*;
	import com.greensock.easing.Expo;
	import com.greensock.easing.Back;

	import screens.*;
	import Enemies.*;
	import utils.*;

	/** The Root class is the topmost display object in your game.
	 *  It is responsible for switching between game and menu. For this, it listens to
	 *  "START_GAME" and "GAME_OVER" events fired by the Menu and Game classes.
	 *  In other words, this class is supposed to control the high level behaviour of your game.
	 */
	public class Root extends Sprite
	{
		private var _currGameIndex:Number;
		private var _currGameState:String;
		private var _appGlobalState:String;

		private var currLevelName:Class;

		private var touch:Touch;
		private var _boostUp:Boolean;
		private var _swipeDir:String;
		private var currentPos:Point;
		private var previousPos:Point;
		private var currY:Number;
		private var currX:Number;
		private var prevY:Number;
		private var prevX:Number;
		private var _distX:Number;
		private var _distY:Number;
		private var _distMin:int = 30; //MINIMUM AMOUNT TO SWIPE
		private var _tileS:int = 30; //RASTR SIZE

		private var _sharedObj:SharedObject;

		private static var sAssets:AssetManager;

		private var _activeScene:Scene;
		private var _currBgr:Scene;
		private var _controlls:ControllScreen;

		private var _startOnlyOnce:int = 1;

		private var _wip:Image;
		private var _wipARR:Array = new Array();
		
		public function Root()
		{
			addEventListener(TitleScreen.START_GAME, touchToStart);
			// addEventListener(ControllScreen.PAUSE_GAME, pauseGame);
			addEventListener("pauseGame", pauseGame);
			addEventListener("loadNewChapter", loadNewLevel);
addEventListener(Crocodile.HERO_SMASH, heroSmash);
// addEventListener(Crocodile.SHOW_PLAYICON, togglePlayIcon);
addEventListener(Crocodile.START_LEVEL, startCurrLevel);
addEventListener(Hero.HERO_WINS, startNewGame);

// touchControll (GameScreen)
// gameLost (GameScreen)
// gameWon (GameScreen)
// wipeDone (WipeScreen)
// swipeDone (BgrScreen)
// zoomDone (BgrScreen)
// backToPlay (CtrlBtn)

			// addEventListener(_activeScene.GAME_OVER,  onGameOver);
			
			// not more to do here -- Startup will call "start" immediately.
		}
		
		public function start(assets:AssetManager):void
		{
			// the asset manager is saved as a static variable; this allows us to easily access
			// all the assets from everywhere by simply calling "Root.assets"

			sAssets = assets;
			addBgr(BgrScreen);
			
			addWIP();

			//*/
			showScene(TitleScreen);
			/*/
			showScene(GamePidala);
			//*/

			addControlls();

			updateSaves(true);

			// If you don't want to support auto-orientation, you can delete this event handler.
			// Don't forget to update the AIR XML accordingly ("aspectRatio" and "autoOrients").
			stage.addEventListener(Event.RESIZE, onResize);
		}

		private function updateSaves(firstTime:Boolean=false):void
		{
			if(firstTime) 
			{
				_currGameIndex = AppConfigClass.load("currGameIndex"); // INDEX OF CURRENT GAME CLASS
	// trace("_currGameIndex: " + _currGameIndex);
				if(_currGameIndex) {
					Constants.CURR_INDEX = _currGameIndex;
				} else {
					_currGameIndex = Constants.CURR_INDEX;
					AppConfigClass.save("currGameIndex", _currGameIndex);
				}
	// trace("_currGameIndex: " + _currGameIndex);
				_currGameState  = AppConfigClass.load("currGameState");
				if(_currGameState) {
					Constants.GAME_STATE = _currGameState;
				} else {
					_currGameState = Constants.GAME_STATE;
					AppConfigClass.save("currGameState", _currGameState);
				}
				_appGlobalState  = AppConfigClass.load("globalState");
				if(_appGlobalState) {
					Constants.GLOB_STATE = _appGlobalState;
				} else {
					_appGlobalState = Constants.GLOB_STATE;
					AppConfigClass.save("globalState", _appGlobalState);
				}
			} else {
				_currGameState = _activeScene.phase;

				AppConfigClass.save("currGameState", _currGameState);
				AppConfigClass.save("globalState", _appGlobalState);
			}

trace(
"_currGameIndex: " + _currGameIndex + "\n" +
"currGameState: " + _currGameState + "\n" +
"globalState: " + _appGlobalState
);

		}

		private function addWIP():void {
// WHALE
			var whale:Image = new Image(assets.getTexture("whale"));
			whale.scaleX = 0;
			whale.scaleY = 0;
			whale.x = Math.round(stage.stageWidth / 2);
			whale.y = Math.round(stage.stageHeight / 5);
			addChild(whale);
			whale.alignPivot();
			_wipARR.push(whale);
// SKUNK
			var skunk:Image = new Image(assets.getTexture("skunk"));
			skunk.scaleX = 0;
			skunk.scaleY = 0;
			skunk.x = Math.round(stage.stageWidth * 0.85);
			skunk.y = Math.round(stage.stageHeight / 5);
			addChild(skunk);
			skunk.alignPivot();
			_wipARR.push(skunk);
// FLY
			var fly:Image = new Image(assets.getTexture("fly"));
			fly.scaleX = 0;
			fly.scaleY = 0;
			fly.x = Math.round(stage.stageWidth / 5);
			fly.y = Math.round(stage.stageHeight  / 2);
			addChild(fly);
			fly.alignPivot();
			_wipARR.push(fly);

// PIDALA
			var pidala:Image = new Image(assets.getTexture("pidala"));
			pidala.scaleX = 0;
			pidala.scaleY = 0;
			pidala.x = Math.round(stage.stageWidth * 0.85);
			pidala.y = Math.round(stage.stageHeight  / 2);
			addChild(pidala);
			pidala.alignPivot();
			_wipARR.push(pidala);
// CRAB
			var crab:Image = new Image(assets.getTexture("crab"));
			crab.scaleX = 0;
			crab.scaleY = 0;
			crab.x = Math.round(stage.stageWidth / 5) + 4;
			crab.y = Math.round(stage.stageHeight * 0.85) + 4;
			addChild(crab);
			crab.alignPivot();
			_wipARR.push(crab);
// HEN
			var slipka:Image = new Image(assets.getTexture("slipka"));
			slipka.scaleX = 0;
			slipka.scaleY = 0;
			slipka.x = Math.round(stage.stageWidth  / 2);
			// slipka.y = Math.round(stage.stageHeight  / 2);
			slipka.y = Math.round(stage.stageHeight * 0.85);
			addChild(slipka);
			slipka.alignPivot();
			_wipARR.push(slipka);


			_wip = new Image(assets.getTexture("wip"));
			_wip.alignPivot();
			_wip.x = Math.ceil(stage.stageWidth / 2);
			_wip.y = Math.ceil(stage.stageHeight / 2) + 5;
			_wip.scaleX = 0;
			_wip.scaleY = 0;
			addChild(_wip);
			// _wipARR.push(_wip);
			
		}

		private function toggleWIP(show:Boolean = false):void {
			if(!_wip) return;
			var scaleVal:int = 0;
			if(show) {
				scaleVal = 1;
			} 
			TweenMax.to(_wip, 0.35, {scale: scaleVal, ease:Back.easeOut});
			// TweenMax.staggerTo([_wipARR], 0.35, {scale: scaleVal, ease:Back.easeOut}, 0.15);

		}

		private function toggleEnemies(show:Boolean = false):void {
			if(!_wip) return;
			// var scaleVal:int = 0;
			// var delT:Number = 0;
			if(show) {
				// scaleVal = 1;
				TweenMax.staggerTo(_wipARR, 0.35, {scale: 1, ease:Back.easeOut, delay: 0.85}, 0.2);
			} else {
				TweenMax.to(_wipARR, 0.35, {scale: 0, ease:Back.easeOut});
			}
		}
		private function addBgr(scene:Class):void
		{
// trace("addBgr fired");
			if (_currBgr) _currBgr.removeFromParent(true);
			_currBgr = new scene() as Scene;

			if (_currBgr == null)
			{
				throw new ArgumentError("Invalid scene: " + scene);
// trace("Invalid scene: " + scene);
			}

			addChild(_currBgr);
			_currBgr.init(stage.stageWidth, stage.stageHeight);
		}


		private function onGameOver(event:Event, score:int):void
		{
// trace("Game Over! Score: " + score);
			showScene(TitleScreen);
			removeEventListener(TouchEvent.TOUCH, touchControll);
		}

		private function heroSmash(event:Event,  param:Object=null):void
		{
			if(param=="ready-to-reset")
			{
trace("HERO_SMASH bubbled up to Root.as");
				// TO DO
				// PLAY WIPE SCREEN
				// RESET CURRENT GAMESCREEN
				// GET REPLAY BTN READY
				startNewGame();
			}
		}
		
		private function touchToStart(event:Event, gameMode:String):void
		{
// trace("Game starts! Mode: " + gameMode);

			// TO DO
			//_activeScene.togglePlayIcon();
			// END TO DO
			startNewGame();
		}


		private function loadNewLevel(event:Event, newLevelNum:int = 0):void {
// trace("load new level:" + newLevelNum);
			if(newLevelNum == 0) {
				toggleChaptBtns();
				toggleWIP();
				scaleScreens("scaleUP");
				// toggleEnemies();
				startNewGame();
			} else {
				trace("work in progress");
				toggleWIP(true);
				// TO DO show "work in progress"
			}
		// TODO
			// CHANGE COSTANTS CURR_INDEX
			// startNewGame();
		}


		private function pauseGame(event:Event):void
		{
			// REMOVE EVENT LISTENER pauseGame
			if (_activeScene && _activeScene.phase == Scene.PHASE_PLAYING) 
			{
trace("PAUSING GAME");
				_activeScene.pause(true);
				removeEventListener(TouchEvent.TOUCH, touchControll);
				scaleScreens();
				_appGlobalState = "controlls_on";

				// return;
			} else {
				scaleScreens("scaleUP");
				_activeScene.pause();
				addEventListener(TouchEvent.TOUCH, touchControll);
				toggleWIP();
				// toggleEnemies();
				_appGlobalState = "game_on";

			}

			updateSaves();
			// _currGameState = _activeScene.phase;

			// AppConfigClass.save("currGameState", _currGameState);
			// AppConfigClass.save("globalState", _appGlobalState);
trace("RESUMING GAME");
		}

		private function scaleScreens(param:String="scaleDOWN"):void
		{
			var scaleNum:Number = 1/3;
			var showChaptBtns:Boolean = true;

			_currBgr.resizeTo(stage.stageWidth, stage.stageHeight, 3);

			if (param == "scaleUP")
			{
				scaleNum = 1;
				showChaptBtns = false;
			}
			/*/
			var tween:Tween = new Tween(_activeScene, 0.5);
			tween.scaleTo(scaleNum);
			Starling.juggler.removeTweens(_activeScene);
			Starling.juggler.add(tween);
			/*/

			toggleChaptBtns(showChaptBtns);
			// toggleEnemies(showChaptBtns);

trace("scaling enemies to scale 0");

			var blurF:BlurFilter = new BlurFilter(0.0, 0.0);

			// _activeScene.filter = blurF;
			_currBgr.filter = blurF;
//
// TO DO GROUP SAME TWEENING OF MULTIPLE ITEMS INTO 1 = TWEENMAX/TWEENLITE
//
			Starling.juggler.tween(_activeScene, 0.6, {
				transition: Transitions.EASE_IN_OUT,
				scale: scaleNum
			});
			Starling.juggler.tween(_currBgr, 0.6, {
				transition: Transitions.EASE_IN_OUT,
				onComplete: function():void { 
					if(scaleNum >= 1) {
						_currBgr.resizeTo(stage.stageWidth, stage.stageHeight);
					} else {
						trace("Staggering enemies from scale 0");
					}
					// toggleChaptBtns();
					},
				scale: scaleNum
			});

//
// TO DO GROUP SAME TWEENING OF MULTIPLE ITEMS INTO 1 = TWEENMAX/TWEENLITE
//

//
// ??? TWEENMAX/TWEENLITE POSSIBLE TWEENING BLUR FILTER ???
//
			Starling.juggler.tween(_currBgr.filter, 0.3, {
				transition: Transitions.EASE_IN_OUT,
				onComplete: function():void { 
					bgrUnBlur();
					},
				blurX: 1.2, blurY: 1.2 
			});
			/*/
/*
tween.onStart = function():void {  };
tween.onUpdate = function():void {  };
tween.onComplete = function():void {  
	// ADD EVENT LISTENER pauseGame
};
tween.delay = 2; 
tween.repeatCount = 3;
tween.reverse = true;
tween.nextTween = explode;
*/
		}

		private function startNewGame(e:Event=null):void
		{
			currLevelName = Constants.LEVELS[_currGameIndex] as Class;
			showScene(currLevelName);

// togglePlayIcon(true);

			addEventListener(TouchEvent.TOUCH, touchControll);
		}

		private function bgrUnBlur():void
		{
			Starling.juggler.tween(_currBgr.filter, 0.3, {
				transition: Transitions.EASE_IN_OUT,
				blurX: 0.0, blurY: 0.0 
			});
		}

		private function addControlls():void
		{
			if(_controlls) _controlls.removeFromParent(true);

			_controlls = new ControllScreen();
			addChild(_controlls);
			_controlls.init(stage.stageWidth, stage.stageHeight);
// UNCOMMENT TEMP ONLY !!!
			toggleControlls();
// UNCOMMENT TEMP ONLY !!!
		}


		private function toggleControlls(param:Boolean=false):void
		{
			_controlls.visible = param;
			if(param) {
				TweenLite.from(_controlls, 2, {alpha: 0});
			}
			if ( _activeScene && _controlls) swapChildren(_activeScene, _controlls);
		}

		private function toggleChaptBtns(showBtns:Boolean = false):void {
			_controlls.toggleChaptBtns(showBtns);
			toggleEnemies(showBtns);
		}
		

		private function touchControll(event:TouchEvent):void
		{
			touch = event.getTouch(stage);

			if(!_activeScene is GameCrocs) return;
			if(event.target is Button) return;

			// GET SWIPE EVENT AND DIRECTION
			if (touch && touch.phase == TouchPhase.MOVED && Scene.PHASE_PLAYING)
			{

				currentPos  = touch.getLocation(stage);
				previousPos = touch.getPreviousLocation(stage);

				currY = currentPos.y;
				currX = currentPos.x;
				prevY = previousPos.y;
				prevX = previousPos.x;

				if(currX>prevX && currY<prevY )
				{
					_swipeDir = "TOPRIGHT";
				}
				if(currX>prevX &&  currY>prevY)
				{
					_swipeDir = "BOTTOMRIGHT";
				}
				if(currX<prevX &&  currY<prevY)
				{
					_swipeDir = "TOPLEFT";
				}
				if(currX<prevX &&  currY>prevY)
				{
					_swipeDir = "BOTTOMLEFT";
				}
				
				_boostUp = true;
			}

			if (touch && touch.phase == TouchPhase.ENDED)
			{
				if (_activeScene.phase == Scene.PHASE_IDLE) 
				{
					
// _activeScene.start();
// toggleControlls(true);
					startCurrLevel(true);
					return;
				}
				if (_activeScene.phase == Scene.PHASE_RESUMED)
				{
// trace("RESUMED, WAITING FOR HERO INIT");
				}
				if (_activeScene.phase == Scene.PHASE_PLAYING) 
				{
					_distX = Math.abs(currX - prevX);
					_distY = Math.abs(currY - prevY);
					if(_distX == 0) _distX = _distMin;
					if(_distY == 0) _distY = _distMin;

// trace("_swipeDir: " + _swipeDir // + "\n"// + "distX: " + _distX // + "\n"// + "distY: " + _distY);
					
					_activeScene.boostHeroUp(_swipeDir, _distX, _distY, _boostUp);
				}
			}
		}
		
// 
// HELPER METHODS
// 

		public static function get assets():AssetManager { return sAssets; }

		private function showScene(scene:Class):void
		{
// trace("showScene fired");
			if (_activeScene) 
			{
				// _activeScene.reset();
				_activeScene.removeFromParent(true);
			}
// trace(_activeScene);
// trace(scene is Class);
			_activeScene = new scene() as Scene;

			if (_activeScene == null)
			{
				throw new ArgumentError("Invalid scene: " + scene);
// trace("Invalid scene: " + scene);
			}

			if(_activeScene == GameCrocs)
			{
				_appGlobalState = "game_on";
			} else if(_activeScene == TitleScreen)
			{
				_appGlobalState = "title_on";
			}

			updateSaves();

			addChild(_activeScene);
			_activeScene.init(stage.stageWidth, stage.stageHeight);
		}

		private function startCurrLevel(param:Boolean=false, event:Event=null):void {

			if(!param || _startOnlyOnce < _activeScene.enemies.length) {
				_startOnlyOnce++;
				return;
			}
			_activeScene.start();
			toggleControlls(true);
			_startOnlyOnce = 1;
		}

		public function onResize(event:ResizeEvent):void
		{
			var current:Starling = Starling.current;
			var scale:Number = current.contentScaleFactor;

			stage.stageWidth  = event.width  / scale;
			stage.stageHeight = event.height / scale;

			current.viewPort.width  = stage.stageWidth  * scale;
			current.viewPort.height = stage.stageHeight * scale;

			if (_currBgr) _currBgr.resizeTo(stage.stageWidth, stage.stageHeight);

			if (_activeScene) _activeScene.resizeTo(stage.stageWidth, stage.stageHeight);
			
			if (_controlls) _controlls.resizeTo(stage.stageWidth, stage.stageHeight);
		}
	}
}