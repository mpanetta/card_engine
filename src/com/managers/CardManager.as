package com.managers
{
  import com.core.error.ErrorBase;

  import flash.events.EventDispatcher;

  public class CardManager extends EventDispatcher
  {
    //
    // Constants.
    //

    //
    // Instance variables.
    //

    private static var _instance:CardManager;

    private var _options:Object;

    //
    // Constructors.
    //

    public function CardManager(sb:SingletonBlocker, options:Object) {
      _options = options;
    }

    public static function initialize(options:Object=null):void {
      _instance = new CardManager(new SingletonBlocker, options);
    }

    public static function get instance():CardManager {
      if(_instance) return _instance;

      throw new ErrorBase(ErrorBase.UNINITIALIZED, "");
    }

    //
    // Getters and setters.
    //

    //
    // Public methods.
    //

    //
    // Private methods.
    //

    private function register():void {
    }

    private function unregister():void {
    }

    //
    // Event handlers.
    //
  }
}

class SingletonBlocker {}