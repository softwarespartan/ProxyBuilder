%% Proxy Objects in Java and Matlab
%
% Dynamically create java.lang.reflect.Proxy objects in Matlab for a given Java interface
%

%% What are Proxy Objects?
% Given a Java Interface, a <http://docs.oracle.com/javase/8/docs/api/java/lang/reflect/Proxy.html java.lang.reflect.Proxy> can be created at runtime which implements that Interface and associated methods.
% A dynamic proxy class (simply referred to as a proxy class) is a class that implements a list of interfaces specified at runtime when the class is created.  
% A proxy instance is an instance of a proxy class. Each proxy instance has an associated invocation handler object, which implements the interface <http://docs.oracle.com/javase/8/docs/api/java/lang/reflect/InvocationHandler.html InvocationHandler>. 
% A method invocation on a proxy instance through one of its proxy interfaces will be dispatched to the invoke method of the instance's invocation handler, 
% passing the proxy instance, a <http://docs.oracle.com/javase/8/docs/api/java/lang/reflect/Method.html java.lang.reflect.Method> object identifying the method that was invoked, and an array of type Object containing the arguments. 
% The invocation handler processes the encoded method invocation as appropriate and the result that it returns will be returned as the result of the method invocation on the proxy instance.
%
% A proxy instance has the following properties:
%
% * Given a proxy instance proxy and one of the interfaces implemented by its proxy class Foo, the following expression will return true: _proxy_ _instanceof_ _Foo_
% * Each proxy instance has an associated invocation handler, the one that was passed to its constructor. The static Proxy.getInvocationHandler method will return the invocation handler associated with the proxy instance passed as its argument.
%
% So what does all this mean?  It means that using Proxys, it is possible to dynamically define 
%
% * <http://docs.oracle.com/javase/8/docs/api/java/awt/event/ActionListener.html ActionListener>
% * <http://docs.oracle.com/javase/8/docs/api/java/util/EventListener.html EventListener> 
% * <http://docs.oracle.com/javase/8/docs/api/java/lang/Runnable.html Runnable>
% * <http://docs.oracle.com/javase/8/docs/api/java/util/concurrent/Callable.html Callable>
% * <http://docs.oracle.com/javase/8/docs/api/java/util/function/package-summary.html Stream Functions> (Consumer<T>, Supplier<T>, Function<T,R>)
%
% and much more within Matlab without having to manage custom Java code.  ProxyBuilder makes it easy to create proxy objects and bind Matlab callbacks within the invocation handler.

%% Configuring ProxyBuilder 
%
% First make sure that the absolute path to the ProxyBuilder.jar has been added to your Matlab classpath.txt (static) or added using javaaddpath('/your/path/ProxyBuilder.jar') which adds the jar file dynamically.  
%
% Suppose you've unziped the ProxyBuilder source code to ~/Dropbox/src/ProxyBuilder
cd ~/Dropbox/src/ProxyBuilder

%%
%
% Get the dynamic java class path 
dynpath = javaclasspath('-dynamic');

%%
% Now add the jar file to the dynamic java class path
if isempty(dynpath) || isempty(regexp(dynpath{1},'ProxyBuilder.jar')); 
    javaaddpath(fullfile(pwd,'ProxyBuilder.jar'));
end

%% ActionListener Example
%
% Here is an example using ProxyBuilder to dynamically create an ActionListener for a JButton callback.
%
% Lets create a simple GUI with a button programatically. 

%% 
% Create a window frame, create a button, add the button to the frame, and finally show the GUI
frame = javax.swing.JFrame;
button = javax.swing.JButton('Button Text');
frame.getContentPane.add(button);
frame.pack;  frame.show;


%% 
% Create action listener class
actionListenerClass = java.lang.Class.forName('java.awt.event.ActionListener');

%%
% Initialize a proxy builder 
proxyBuilder = ProxyBuilder(actionListenerClass);

%%
% Create proxy class for action listener with callback
[proxy,handler] = proxyBuilder.initForMethod('actionPerformed','@(e)disp(e.paramString)');

%%
% Do a quick sanity check to confirm that indeed proxy will pass for an ActionListener 
isa(proxy,'java.awt.event.ActionListener')

%% 
% Register the actionListenerProxy with the button
button.addActionListener(proxy);

%% 
% Now when you click the GUI button you should see 
%
%  "ACTION_PERFORMED,cmd=Button Text,when=1421687267051,modifiers=Button1" 
%
% written to the command window.

%%
% Remember that the InvocationHandler is mapping the actionListener method calls to our callback.  To see this explicitly, we can look at the handler invocation mapping
handler.invocationMap.get('actionPerformed')

%%
% If there are multiple interface methods to assign callbacks for, simply add additional entries in the handler.invocationMap
handler.invocationMap.put('funcName','@(arg)manipulate(arg)');

%%
% View final invocation mapping 
handler.invocationMap