package screens
{
	import flash.geom.*;
	import flash.net.SharedObject;

	import starling.core.Starling;
	import starling.display.*;
	import starling.events.*;
	import starling.utils.AssetManager;
	import starling.utils.Color;
	import starling.textures.Texture;
	
	public class BgrScreen extends Scene
	{
		public static const START_GAME:String = "startGame";

		private var _screenW:Number;
		private var _screenH:Number;

		private var _bgr:Image;

		public function BgrScreen():void
		{ 
			// addEventListener (Event.ADDED_TO_STAGE, onAddedToStage);
		}

		override public function init(width:Number, height:Number):void
		{
			super.init(width, height);
			_screenW = width;
			_screenH = height;

			addBgr();
trace("BgrScreen added to stage");
		}

		override public function resizeTo(width:Number, height:Number, multiply:int=1):void
		{
			super.init(width, height);

			_screenW = width * multiply;
			_screenH = height * multiply;

			redrawBgr();
		}
		private function redrawBgr():void
		{
			if(_bgr)
			{
				_bgr.width = _screenW;
				_bgr.height = _screenH;
			}
		}

		private function addBgr():void
		{
// trace("adding Background");
			
			var tile:Texture = Root.assets.getTexture("square-rastr-pattern");
			_bgr = new Image(tile);
			_bgr.width = _screenW;
			_bgr.height = _screenH;
			_bgr.tileGrid = new Rectangle(0, 0, tile.width, tile.height);
			
			addChild(_bgr);
		}
	}
}