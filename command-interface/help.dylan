module: command-interface
synopsis: Reusable help command.
author: Ingo Albrecht <prom@berlin.ccc.de>
copyright: see accompanying file LICENSE

define method root-add-help (root :: <command-root>)
 => ();
  build-command(root, "help",
                node-class: <command-wrapper>,
                root: root,
                handler: help-handler);
end method;

define method help-handler (parser :: <command-parser>)
 => ();
  let nodes = reverse(parser-nodes(parser));
  let tokens = reverse(parser-tokens(parser));

  // skip "help"
  nodes := tail(nodes);
  tokens := tail(tokens);

  // print help
  show-command-help(nodes, tokens);
end method;

define method show-command-help (nodes :: <sequence>, tokens :: <sequence>)
  => ();
  let cmd :: false-or(<command-command>) = #f;
  let cmd-title :: <list> = #();
  let cmd-help :: false-or(<string>) = #f;

  for (token in tokens, node in nodes)
    if (instance?(node, <command-symbol>))
      if (~cmd)
        cmd-title := add(cmd-title, as(<string>, node-symbol(node)));
      end if;
    end if;
    if (instance?(node, <command-command>))
      cmd := node;
      if (command-help(node))
        cmd-help := command-help(node);
      end if;
    end if;
  end for;

  if (~cmd)
    error("Incomplete command.");
  end;

  cmd-title := reverse(cmd-title);
  cmd-title := map(as-uppercase, cmd-title);

  format-out("\n    %s\n\n", join(cmd-title, " "));
  format-out("    %s\n\n",
             if (cmd-help)
               cmd-help
             else
               "No help."
             end);

  for (parameter in command-parameters(cmd))
    let parmhelp = parameter-help(parameter);
    if (~parmhelp)
      parmhelp := "No help.";
    end;
    format-out("    PARAMETER %s\n     %s\n", parameter-name(parameter), parmhelp);
  end;
end method;
