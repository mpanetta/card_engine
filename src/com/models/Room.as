package com.models
{
  import com.core.messageBus.MessageBus;
  import com.core.net.NetManager;
  import com.core.net.NetMessage;
  import com.events.RoomMessage;

  import flash.events.EventDispatcher;

  public class Room extends EventDispatcher
  {
    //
    // Constants.
    //

    //
    // Instance variables.
    //

    private var _name:String;

    //
    //  Constructors.
    //

    public function Room(name:String) {
      super();

      if(!name)
        throw new Error('Name can not be null.');

      _name = name;

      register();
    }

    //
    // Getters and setters.
    //

    public function get name():String { return _name; }

    //
    // Public methods.
    //

    //
    // Private methods.
    //

    private function register():void {
      MessageBus.addListener(NetMessage.RECEIVED_MESSAGE, netMessage_receivedMessage);
    }

    private function unregister():void {
      MessageBus.removeListener(NetMessage.RECEIVED_MESSAGE, netMessage_receivedMessage);
    }

    public function sendJoinReq():void {
      send('join_req', { room_name:_name })
    }

    public function sendInteract(subCmd:String, params=null):void {
      if(params == null) params = {};

      params.sub_cmd = subCmd;
      params.room_name = _name;

      send('interact', params);
    }

    private function send(command:String, params:Object=null):void {
      NetManager.instance.deliverMessage(command, params);
    }

    private function handleReceivedMessage(command:String, params:Object):void {
      if((params == null) || (params.room_name != _name))
        return;

      switch(command) {
        case 'join_res':
          var eventType:String = (params.success) ? RoomMessage.JOIN_SUCCEEDED : RoomMessage.JOIN_FAILED;
          dispatchEvent(new RoomMessage(eventType));
          break;
        case 'interact':
          dispatchEvent(new RoomMessage(('ROOM_MESSAGE_' + params.sub_cmd).toUpperCase(), params));
          dispatchEvent(new RoomMessage(RoomMessage.INTERACT, params));
          break;
        default:
          throw new Error('Unknown command: ' + command);
      }
    }

    //
    // Event handlers.
    //

    private function netMessage_receivedMessage(event:NetMessage):void {
      handleReceivedMessage(event.command, event.params);
    }
  }
}