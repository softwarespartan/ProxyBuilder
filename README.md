# ProxyBuilder
Dynamically create java.lang.reflect.Proxy objects in Matlab for a given Java interface 

<html>
    <head>
      <meta http-equiv="Content-Type" content="text/html; charset=utf-8">
      <link rel="stylesheet" type="text/css" href="README.css">
  <title>Proxy Objects in Java and Matlab</title><meta name="generator" content="MATLAB 8.4"><link rel="schema.DC" href="http://purl.org/dc/elements/1.1/"><meta name="DC.date" content="2015-01-19"><meta name="DC.source" content="ProxyObjects.m"><style type="text/css">
  </style></head><body><div class="content"><h2>Contents</h2><div><ul><li><a href="#1">What are Proxy Objects?</a></li><li><a href="#2">Configuring ProxyBuilder</a></li><li><a href="#5">ActionListener Example</a></li></ul></div><h2>What are Proxy Objects?<a name="1"></a></h2><p>Given a Java Interface, a <a href="http://docs.oracle.com/javase/8/docs/api/java/lang/reflect/Proxy.html">java.lang.reflect.Proxy</a> can be created at runtime which implements that Interface and associated methods. A dynamic proxy class (simply referred to as a proxy class) is a class that implements a list of interfaces specified at runtime when the class is created. A proxy instance is an instance of a proxy class. Each proxy instance has an associated invocation handler object, which implements the interface <a href="http://docs.oracle.com/javase/8/docs/api/java/lang/reflect/InvocationHandler.html">InvocationHandler</a>. A method invocation on a proxy instance through one of its proxy interfaces will be dispatched to the invoke method of the instance's invocation handler, passing the proxy instance, a <a href="http://docs.oracle.com/javase/8/docs/api/java/lang/reflect/Method.html">java.lang.reflect.Method</a> object identifying the method that was invoked, and an array of type Object containing the arguments. The invocation handler processes the encoded method invocation as appropriate and the result that it returns will be returned as the result of the method invocation on the proxy instance.</p><p>A proxy instance has the following properties:</p><div><ul><li>Given a proxy instance proxy and one of the interfaces implemented by its proxy class Foo, the following expression will return true: <i>proxy</i> <i>instanceof</i> <i>Foo</i></li><li>Each proxy instance has an associated invocation handler, the one that was passed to its constructor. The static Proxy.getInvocationHandler method will return the invocation handler associated with the proxy instance passed as its argument.</li></ul></div><p>So what does all this mean?  It means that using Proxys, it is possible to dynamically define</p><div><ul><li><a href="http://docs.oracle.com/javase/8/docs/api/java/awt/event/ActionListener.html">ActionListener</a></li><li><a href="http://docs.oracle.com/javase/8/docs/api/java/util/EventListener.html">EventListener</a></li><li><a href="http://docs.oracle.com/javase/8/docs/api/java/lang/Runnable.html">Runnable</a></li><li><a href="http://docs.oracle.com/javase/8/docs/api/java/util/concurrent/Callable.html">Callable</a></li><li><a href="http://docs.oracle.com/javase/8/docs/api/java/util/function/package-summary.html">Stream Functions</a> (Consumer&lt;T&gt;, Supplier&lt;T&gt;, Function&lt;T,R&gt;)</li></ul></div><p>and much more within Matlab without having to manage custom Java code.  ProxyBuilder makes it easy to create proxy objects and bind Matlab callbacks within the invocation handler.</p><h2>Configuring ProxyBuilder<a name="2"></a></h2><p>First make sure that the absolute path to the ProxyBuilder.jar has been added to your Matlab classpath.txt (static) or added using javaaddpath('/your/path/ProxyBuilder.jar') which adds the jar file dynamically.</p><p>Suppose you've unziped the ProxyBuilder source code to ~/Dropbox/src/ProxyBuilder</p><pre class="codeinput">cd <span class="string">~/Dropbox/src/ProxyBuilder</span>
</pre><p>Get the dynamic java class path</p><pre class="codeinput">dynpath = javaclasspath(<span class="string">'-dynamic'</span>);
</pre><p>Now add the jar file to the dynamic java class path</p><pre class="codeinput"><span class="keyword">if</span> isempty(dynpath) || isempty(regexp(dynpath{1},<span class="string">'ProxyBuilder.jar'</span>));
    javaaddpath(fullfile(pwd,<span class="string">'ProxyBuilder.jar'</span>));
<span class="keyword">end</span>
</pre><h2>ActionListener Example<a name="5"></a></h2><p>Here is an example using ProxyBuilder to dynamically create an ActionListener for a JButton callback.</p><p>Lets create a simple GUI with a button programatically.</p><p>Create a window frame, create a button, add the button to the frame, and finally show the GUI</p><pre class="codeinput">frame = javax.swing.JFrame;
button = javax.swing.JButton(<span class="string">'Button Text'</span>);
frame.getContentPane.add(button);
frame.pack;  frame.show;
</pre><p>Create action listener class</p><pre class="codeinput">actionListenerClass = java.lang.Class.forName(<span class="string">'java.awt.event.ActionListener'</span>);
</pre><p>Initialize a proxy builder</p><pre class="codeinput">proxyBuilder = ProxyBuilder(actionListenerClass);
</pre><p>Create proxy class for action listener with callback</p><pre class="codeinput">[proxy,handler] = proxyBuilder.initForMethod(<span class="string">'actionPerformed'</span>,<span class="string">'@(e)disp(e.paramString)'</span>);
</pre><pre class="codeoutput">added interface method: actionPerformed
</pre><p>Do a quick sanity check to confirm that indeed proxy will pass for an ActionListener</p><pre class="codeinput">isa(proxy,<span class="string">'java.awt.event.ActionListener'</span>)
</pre><pre class="codeoutput">
ans =

     1
</pre><p>Register the actionListenerProxy with the button</p><pre class="codeinput">button.addActionListener(proxy);
</pre><p>Now when you click the GUI button you should see</p><pre>"ACTION_PERFORMED,cmd=Button Text,when=1421687267051,modifiers=Button1"</pre><p>written to the command window.</p><p>Remember that the InvocationHandler is mapping the actionListener method calls to our callback.  To see this explicitly, we can look at the handler invocation mapping</p><pre class="codeinput">handler.invocationMap.get(<span class="string">'actionPerformed'</span>)
</pre><pre class="codeoutput">
ans =

@(e)disp(e.paramString)
</pre><p>If there are multiple interface methods to assign callbacks for, simply add additional entries in the handler.invocationMap</p><pre class="codeinput">handler.invocationMap.put(<span class="string">'funcName'</span>,<span class="string">'@(arg)manipulate(arg)'</span>);
</pre><p>View final invocation mapping</p><pre class="codeinput">handler.invocationMap
</pre><pre class="codeoutput"> 
ans =
 
{funcName=@(arg)manipulate(arg), actionPerformed=@(e)disp(e.paramString)}
</pre><p class="footer"><br><a href="http://www.mathworks.com/products/matlab/">Published with MATLAB&reg; R2014b</a><br></p></div>
</body></html>
