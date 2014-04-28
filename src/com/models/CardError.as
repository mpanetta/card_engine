package com.models
{
  import com.core.error.ErrorBase;

  public class CardError extends ErrorBase
  {
    //
    // Constants.
    //

    public static const NUM_ALREADY_SET:String = "Num has already been set and cannot be set again.";
    public static const ALREADY_DISPOSED:String = "Object already disposed.";
    public static const MUST_OVERRIDE:String = "Method must be overriden in derived class.";
    public static const MULTIPLE_ID:String = "Attempted to use id multiple times.";
    public static const UNKOWN_STANDARD_SUIT:String = "Unkown suit num for standard suit.";
    public static const NO_ID:String = "Could not find object with id provided.";
    public static const MISSING_CARD_IMAGE:String = "Art for card could not be found.";
    public static const UNKOWN_DIFFICULTY:String = "Attempted to pass an unsupported difficulty to the game";

    //
    // Instance variables.
    //

    //
    // Constructors.
    //

    public function CardError(type:String, details:String="", id:*=0) {
      super(type, details, id);
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

    //
    // Event handlers.
    //
  }
}