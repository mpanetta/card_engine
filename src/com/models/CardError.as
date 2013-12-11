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